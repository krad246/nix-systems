{
  config,
  lib,
  ...
}: let
  configurations = config.dendritic.configurations;
  profileNames = config.dendritic.internal.profileNames;
  capabilityTags = config.dendritic.internal.capabilityTags;

  mergeArgs = field: contributions:
    lib.mergeAttrsList (map (contribution: contribution.${field} or {}) contributions);

  profileSystemModules = nativeClass: tags:
    lib.concatMap (tag:
      if lib.elem tag profileNames
      then (configurations.perTag.${tag}.perClass.${nativeClass} or {}).modules or []
      else assert lib.assertMsg (lib.elem tag capabilityTags) "dendritic.configurations: tag ${tag} is not a canonical profile aspect or framework capability"; [])
    tags;

  profileHomeModules = username: tags:
    lib.concatMap (tag:
      if lib.elem tag profileNames
      then let
        contribution = configurations.perTag.${tag}.perClass.homeManager or {};
      in
        (contribution.modules or []) ++ (contribution.users.${username}.modules or [])
      else assert lib.assertMsg (lib.elem tag capabilityTags) "dendritic.configurations: tag ${tag} is not a canonical profile aspect or framework capability"; [])
    tags;

  profileContribution = tag:
    if lib.elem tag profileNames
    then configurations.perTag.${tag}
    else assert lib.assertMsg (lib.elem tag capabilityTags) "dendritic.configurations: tag ${tag} is not a canonical profile aspect or framework capability"; {};
in {
  options.dendritic.internal.systemDeclarations = lib.mkOption {
    type = lib.types.attrsOf lib.types.raw;
    readOnly = true;
    internal = true;
  };

  config.dendritic.internal.systemDeclarations = lib.pipe configurations.hosts [
    (lib.filterAttrs (_: host: host.enable))
    (lib.mapAttrs (hostName: host: let
      class = configurations.classes.${host.class} or (throw "dendritic.configurations: host ${hostName} refers to unknown class ${host.class}");
      baseContributions = [configurations.shared];
      rootTagContributions = map (tag: (profileContribution tag).perClass.${class.nativeClass} or {}) configurations.defaults.tags;
      hostTagContributions = map (tag: (profileContribution tag).perClass.${class.nativeClass} or {}) host.tags;
      rootHomeTagContributions = map (tag: (profileContribution tag).perClass.homeManager or {}) configurations.defaults.tags;
      hostHomeTagContributions = map (tag: (profileContribution tag).perClass.homeManager or {}) host.tags;
      systemContributions = baseContributions ++ rootTagContributions ++ hostTagContributions ++ [host];
      baseModules =
        configurations.shared.modules
        ++ profileSystemModules class.nativeClass configurations.defaults.tags;
      tagModules = profileSystemModules class.nativeClass host.tags;
      selectedUsers =
        lib.filterAttrs (
          username: _: configurations.users ? ${username} && configurations.users.${username}.enable
        )
        host.users;
    in {
      inherit (host) enable outputName hostPlatforms buildPlatforms crossCompile variants;
      tags = configurations.defaults.tags ++ host.tags;
      inherit (host) class;
      inherit (class) nativeClass;
      inherit baseModules tagModules;
      hostModules = host.modules;
      modules = baseModules ++ tagModules ++ host.modules;
      specialArgs = lib.mergeAttrsList [
        configurations.globalArgs
        configurations.earlyModuleArgs
        (mergeArgs "specialArgs" systemContributions)
      ];
      lateModuleArgs = lib.mergeAttrsList [
        configurations.lateModuleArgs
        (mergeArgs "lateModuleArgs" systemContributions)
      ];
      users =
        lib.mapAttrs (username: hostLayer: let
          user = configurations.users.${username};
          userContributions =
            [configurations.shared]
            ++ rootHomeTagContributions
            ++ map (tag: configurations.perTag.${tag}.perClass.homeManager or {}) user.tags
            ++ hostHomeTagContributions
            ++ map (tag: configurations.perTag.${tag}.perClass.homeManager or {}) hostLayer.tags
            ++ [user hostLayer];
          baseUserModules =
            user.modules
            ++ profileHomeModules username configurations.defaults.tags
            ++ profileHomeModules username user.tags;
          taggedUserModules =
            profileHomeModules username host.tags
            ++ profileHomeModules username hostLayer.tags;
        in {
          inherit (hostLayer) outputName;
          tags = user.tags ++ hostLayer.tags;
          baseModules = baseUserModules;
          tagModules = taggedUserModules;
          hostModules = hostLayer.modules;
          modules = baseUserModules ++ taggedUserModules ++ hostLayer.modules;
          extraSpecialArgs = lib.mergeAttrsList [
            configurations.globalArgs
            (mergeArgs "specialArgs" userContributions)
            (mergeArgs "extraSpecialArgs" userContributions)
          ];
          specialArgs = lib.mergeAttrsList [
            configurations.globalArgs
            configurations.earlyModuleArgs
            (mergeArgs "specialArgs" userContributions)
          ];
          lateModuleArgs = lib.mergeAttrsList [
            configurations.lateModuleArgs
            (mergeArgs "lateModuleArgs" userContributions)
          ];
        })
        selectedUsers;
      metadata = {
        inherit hostName;
        class = {
          name = host.class;
          inherit (class) metadata nativeClass;
        };
        tags = map (tag: {
          name = tag;
          meta = configurations.perTag.${tag}.meta or {};
          passthru = configurations.perTag.${tag}.passthru or {};
        }) (configurations.defaults.tags ++ host.tags);
        host = host.metadata;
      };
    }))
  ];
}
