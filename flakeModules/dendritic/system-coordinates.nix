{
  config,
  lib,
  ...
}: let
  configurations = config.dendritic.configurations;
  expectedNativeClass = hostPlatform: let
    platform = lib.systems.parse.mkSystemFromString hostPlatform.system;
  in
    if lib.systems.inspect.predicates.isDarwin platform
    then "darwin"
    else if lib.systems.inspect.predicates.isLinux platform
    then "nixos"
    else throw "dendritic.configurations: unsupported host platform ${hostPlatform.system}";

  architecture = hostPlatform: builtins.head (lib.splitString "-" hostPlatform.system);
in {
  options.dendritic.internal.systemCoordinates = lib.mkOption {
    type = lib.types.listOf lib.types.raw;
    readOnly = true;
    internal = true;
  };

  config.dendritic.internal.systemCoordinates = lib.concatLists (lib.mapAttrsToList (hostName: declaration:
    map (hostPlatform: let
      buildPlatform =
        if declaration.buildPlatform == null
        then hostPlatform
        else declaration.buildPlatform;
      arch = architecture hostPlatform;
      archLayer = configurations.perArch.${arch} or {};
      systemLayer = configurations.perSystem.${hostPlatform.system} or {};
      coordinate = {
        inherit hostName hostPlatform buildPlatform declaration;
        inherit (declaration) class nativeClass outputName crossCompile variants;
        modules =
          declaration.baseModules
          ++ (archLayer.modules or [])
          ++ (systemLayer.modules or [])
          ++ declaration.tagModules
          ++ declaration.hostModules;
        users =
          lib.mapAttrs (username: user: {
            inherit (user) tags;
            modules =
              user.baseModules
              ++ (archLayer.users.${username}.modules or [])
              ++ (systemLayer.users.${username}.modules or [])
              ++ user.tagModules
              ++ user.hostModules;
          })
          declaration.users;
        metadata = {
          declaration = declaration.metadata;
          platform = {
            inherit arch;
            inherit (hostPlatform) system;
            architecture = archLayer.metadata or {};
            systemLayer = systemLayer.metadata or {};
          };
        };
      };
    in
      assert lib.assertMsg (declaration.nativeClass == expectedNativeClass hostPlatform) "dendritic.configurations: class ${declaration.class} resolves to ${declaration.nativeClass}, which conflicts with host platform ${hostPlatform.system}";
      assert lib.assertMsg (buildPlatform.system == hostPlatform.system || declaration.crossCompile) "dendritic.configurations: host platform ${hostPlatform.system} requires crossCompile = true for build platform ${buildPlatform.system}"; coordinate)
    declaration.hostPlatforms)
  config.dendritic.internal.systemDeclarations);
}
