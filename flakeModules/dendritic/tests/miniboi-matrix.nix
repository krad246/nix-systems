{
  config,
  lib,
  ...
}: let
  flakeConfig = config;
  # flake-parts exposes the declared evaluation-system universe on the root
  # config; the fixed-point matrix spans this same universe rather than
  # assuming that the current perSystem evaluation is the only build host.
  flakeSystems = lib.unique (lib.filter (system: system != "x86_64-darwin") flakeConfig.systems);
  systemCoordinates = flakeConfig.dendritic.internal.systemCoordinates;
  miniboiCoordinates = lib.filter (coordinate: coordinate.hostName == "miniboi") systemCoordinates;
  variantUsesVirtualisation = variant:
    variant.virtualisation != null || lib.elem "virtualisation" variant.tags;

  virtualisationEnabled = variant:
    flakeConfig.dendritic.virtualisation.enable
    && (
      if variant.virtualisation == null
      then lib.elem "virtualisation" variant.tags
      else variant.virtualisation.enable
    );

  validBuildSystems = coordinate: let
    candidates =
      if coordinate.buildPlatforms == null
      then flakeSystems
      else map (platform: platform.system) coordinate.buildPlatforms;
  in
    lib.filter (buildPlatform:
      buildPlatform == coordinate.hostPlatform.system || coordinate.crossCompile)
    candidates;

  coordinateName = coordinate:
    if coordinate.outputName == null
    then coordinate.hostName
    else coordinate.outputName;

  hostOutputName = coordinate:
    if lib.count (candidate: candidate.hostName == coordinate.hostName) systemCoordinates == 1
    then coordinateName coordinate
    else "${coordinateName coordinate}-${coordinate.hostPlatform.system}";

  enabledVariants = coordinate:
    lib.filterAttrs (_: variant:
      flakeConfig.dendritic.configurations.defaults.variants.enableFlakeOutputs
      && flakeConfig.dendritic.configurations.defaults.variants.enable
      && variant.enableFlakeOutput
      && variant.enable
      && (!variantUsesVirtualisation variant || virtualisationEnabled variant))
    coordinate.declaration.variants;

  packageCoordinates = lib.concatMap (coordinate: let
    variants = enabledVariants coordinate;
    buildPlatforms = validBuildSystems coordinate;
    preferredBuildPlatform =
      if lib.elem coordinate.hostPlatform.system buildPlatforms
      then coordinate.hostPlatform.system
      else builtins.head buildPlatforms;
    rows = runnerPlatform: buildPlatform: selectedVariants:
      lib.mapAttrsToList (variantName: variant: {
        inherit coordinate buildPlatform runnerPlatform variantName variant;
      })
      selectedVariants;
  in
    (lib.concatMap (buildPlatform: rows buildPlatform buildPlatform variants) buildPlatforms)
    ++ (lib.concatMap (runnerPlatform:
      rows runnerPlatform preferredBuildPlatform (lib.filterAttrs (_: virtualisationEnabled) variants))
    (lib.filter (runnerPlatform: !lib.elem runnerPlatform buildPlatforms) flakeSystems)))
  miniboiCoordinates;

  packageName = packageCoordinate: "${hostOutputName packageCoordinate.coordinate}-${packageCoordinate.variantName}";
  configurationNames = lib.concatMap (coordinate:
    [
      (hostOutputName coordinate)
    ]
    ++ map (variantName: "${hostOutputName coordinate}-${variantName}") (builtins.attrNames (enabledVariants coordinate)))
  miniboiCoordinates;

  expectedPackageNames = system:
    builtins.sort builtins.lessThan (map packageName (lib.filter (packageCoordinate:
      packageCoordinate.runnerPlatform == system)
    packageCoordinates));
in {
  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: let
    expectedNames = expectedPackageNames system;
    actualNames = map packageName (lib.filter (packageCoordinate:
      lib.hasAttr (packageName packageCoordinate) config.packages)
    packageCoordinates);
    matrixPackages = lib.concatMap (flakeSystem: let
      packages = lib.attrByPath ["packages" flakeSystem] {} flakeConfig.flake;
    in
      map (packageCoordinate: lib.getAttr (packageName packageCoordinate) packages) (lib.filter (packageCoordinate:
        packageCoordinate.runnerPlatform == flakeSystem)
      packageCoordinates))
    flakeSystems;
    matrixPackageNames = lib.concatMap (flakeSystem:
      map packageName (lib.filter (packageCoordinate:
        packageCoordinate.runnerPlatform == flakeSystem)
      packageCoordinates))
    flakeSystems;
    miniboiConfigurations = lib.filterAttrs (name: _: lib.elem name configurationNames) flakeConfig.flake.nixosConfigurations;
    matrixToplevels = map (configuration: configuration.config.system.build.toplevel) (lib.attrValues miniboiConfigurations);
  in {
    dendritic.assertions = [
      {
        assertion = lib.all (packageCoordinate: let
          package = lib.getAttr (packageName packageCoordinate) (lib.getAttr packageCoordinate.runnerPlatform flakeConfig.flake.packages);
        in
          package.stdenv.buildPlatform.system
          == packageCoordinate.runnerPlatform
          && package.stdenv.hostPlatform.system == packageCoordinate.runnerPlatform)
        packageCoordinates;
        message = "every Miniboi package projection has a native runner for its package namespace";
      }
      {
        assertion = lib.all (name: lib.hasAttr name flakeConfig.flake.nixosConfigurations) configurationNames;
        message = "Miniboi publishes its root system and every declared VM variant for every host platform";
      }
      {
        assertion = builtins.sort builtins.lessThan actualNames == expectedNames;
        message = "Miniboi package projections are sparse but complete on each declared build platform";
      }
      {
        assertion = builtins.sort builtins.lessThan matrixPackageNames == builtins.sort builtins.lessThan (map packageName packageCoordinates);
        message = "Miniboi package projections cover every builder and non-Linux VM runner fixed point";
      }
      {
        assertion = lib.all (packageCoordinate:
          packageCoordinate.runnerPlatform
          == packageCoordinate.buildPlatform
          || lib.elem "virtualisation" packageCoordinate.variant.tags)
        packageCoordinates;
        message = "only virtualisation variants receive a runner projection outside the declared builder table";
      }
      {
        assertion = let
          darwinVmNogui = lib.filter (packageCoordinate:
            packageCoordinate.runnerPlatform
            == "aarch64-darwin"
            && packageCoordinate.variantName == "vm-nogui")
          packageCoordinates;
          guestPlatforms = builtins.sort builtins.lessThan (map (packageCoordinate:
            packageCoordinate.coordinate.hostPlatform.system)
          darwinVmNogui);
        in
          guestPlatforms
          == ["aarch64-linux" "x86_64-linux"]
          && lib.all (packageCoordinate: let
            package = lib.getAttr (packageName packageCoordinate) (lib.getAttr packageCoordinate.runnerPlatform flakeConfig.flake.packages);
          in
            package.meta.mainProgram
            == "run-miniboi-vm"
            && package.stdenv.buildPlatform.system == "aarch64-darwin"
            && package.stdenv.hostPlatform.system == "aarch64-darwin")
          darwinVmNogui;
        message = "Darwin exposes runnable vm-nogui launchers for both Linux Miniboi guest targets";
      }
    ];

    checks.dendritic-miniboi-matrix = pkgs.runCommand "dendritic-miniboi-matrix" {
      buildInputs = matrixToplevels ++ matrixPackages;
    } "touch $out";
  };
}
