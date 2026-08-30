{
  config,
  lib,
  ...
}: let
  configurations = config.dendritic.configurations;
  profileNames = config.dendritic.internal.profileNames;

  mergeArgs = field: contributions:
    lib.mergeAttrsList (map (contribution: contribution.${field} or {}) contributions);

  profile = nativeClass: tag: let
    overlay = configurations.perTag.${tag} or {};
    classContribution = overlay.perClass.${nativeClass} or {};
    homeContribution = overlay.perClass.home or {};
  in
    assert lib.assertMsg (lib.elem tag profileNames) "dendritic.configurations: tag ${tag} is not a canonical profile aspect"; {
      system = classContribution.modules or [];
      home = homeContribution.modules or [];
    };

  homeContributions = username: contribution:
    contribution.users.${username}.modules or [];

  profileHomeModules = username: tag: let
    selected = profile "home" tag;
    overlay = configurations.perTag.${tag} or {};
  in
    selected.home ++ (overlay.perClass.home.users.${username}.modules or []);
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
      classNames = [class.nativeClass];
      rootProfiles = map (profile class.nativeClass) configurations.tags;
      hostProfiles = map (profile class.nativeClass) host.tags;
      baseContributions =
        [configurations.shared]
        ++ map (className: configurations.perClass.${className} or {}) classNames;
      homeClassLayer = configurations.perClass.home or {};
      rootTagContributions = map (tag: configurations.perTag.${tag}.perClass.${class.nativeClass} or {}) configurations.tags;
      hostTagContributions = map (tag: configurations.perTag.${tag}.perClass.${class.nativeClass} or {}) host.tags;
      rootHomeTagContributions = map (tag: configurations.perTag.${tag}.perClass.home or {}) configurations.tags;
      hostHomeTagContributions = map (tag: configurations.perTag.${tag}.perClass.home or {}) host.tags;
      systemContributions = baseContributions ++ rootTagContributions ++ hostTagContributions ++ [host];
      baseModules =
        configurations.shared.modules
        ++ lib.concatMap (selected: selected.system) rootProfiles
        ++ lib.concatMap (contribution: contribution.modules or []) (lib.tail baseContributions);
      tagModules = lib.concatMap (selected: selected.system) hostProfiles;
      selectedUsers =
        lib.filterAttrs (
          username: _: configurations.users ? ${username} && configurations.users.${username}.enable
        )
        host.users;
    in {
      inherit (host) enable outputName hostPlatforms buildPlatform crossCompile variants;
      tags = configurations.tags ++ host.tags;
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
            [configurations.shared homeClassLayer]
            ++ map (className: configurations.perClass.${className} or {}) classNames
            ++ rootHomeTagContributions
            ++ map (tag: configurations.perTag.${tag}.perClass.home or {}) user.tags
            ++ hostHomeTagContributions
            ++ map (tag: configurations.perTag.${tag}.perClass.home or {}) hostLayer.tags
            ++ [user hostLayer];
          baseUserModules =
            user.modules
            ++ (homeClassLayer.modules or [])
            ++ (homeClassLayer.users.${username}.modules or [])
            ++ lib.concatMap (profileHomeModules username) configurations.tags
            ++ lib.concatMap (homeContributions username) (lib.tail baseContributions)
            ++ lib.concatMap (profileHomeModules username) user.tags;
          taggedUserModules =
            lib.concatMap (profileHomeModules username) host.tags
            ++ lib.concatMap (profileHomeModules username) hostLayer.tags;
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
        }) (configurations.tags ++ host.tags);
        host = host.metadata;
      };
    }))
  ];
}
