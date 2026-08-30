{
  config,
  lib,
  ...
}: let
  flakeConfig = config;
  # flake-parts exposes the declared evaluation-system universe on the root
  # config; the fixed-point matrix spans this same universe rather than
  # assuming that the current perSystem evaluation is the only build host.
  flakeSystems = flakeConfig.systems;
  systemCoordinates = flakeConfig.dendritic.internal.systemCoordinates;
  miniboiCoordinates = lib.filter (coordinate: coordinate.hostName == "miniboi") systemCoordinates;

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
      flakeConfig.dendritic.configurations.variants.enableFlakeOutputs
      && flakeConfig.dendritic.configurations.variants.enable
      && variant.enableFlakeOutput
      && variant.enable)
    coordinate.declaration.variants;

  packageCoordinates = lib.concatMap (coordinate:
    lib.mapAttrsToList (variantName: variant: {
      inherit coordinate variantName variant;
    }) (lib.filterAttrs (_: variant: variant.package != null) (enabledVariants coordinate)))
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
      packageCoordinate.coordinate.buildPlatform.system == system)
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
        packageCoordinate.coordinate.buildPlatform.system == flakeSystem)
      packageCoordinates))
    flakeSystems;
    matrixPackageNames = lib.concatMap (flakeSystem:
      map packageName (lib.filter (packageCoordinate:
        packageCoordinate.coordinate.buildPlatform.system == flakeSystem)
      packageCoordinates))
    flakeSystems;
    miniboiConfigurations = lib.filterAttrs (name: _: lib.elem name configurationNames) flakeConfig.flake.nixosConfigurations;
    matrixToplevels = map (configuration: configuration.config.system.build.toplevel) (lib.attrValues miniboiConfigurations);
  in {
    dendritic.assertions = [
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
        message = "Miniboi package projections cover every fixed point across the declared flake systems";
      }
    ];

    checks.dendritic-miniboi-matrix = pkgs.runCommand "dendritic-miniboi-matrix" {
      buildInputs = matrixToplevels ++ matrixPackages;
    } "touch $out";
  };
}
