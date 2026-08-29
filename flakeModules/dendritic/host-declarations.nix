{
  config,
  lib,
  ...
}: let
  configurations = config.dendritic.configurations;
  profileLayers = config.dendritic.internal.profileLayers;

  profile = nativeClass: tag: let
    overlay = configurations.perTag.${tag} or {};
    layer = profileLayers.${tag} or (throw "dendritic.configurations: tag ${tag} is not a profile overlay in inputs.dendritic/modules/profiles");
  in {
    system = layer.${nativeClass} ++ (overlay.modules or []);
    home = layer.homeManager ++ (overlay.homeModules or []);
  };

  homeContributions = username: contribution:
    (contribution.homeModules or []) ++ (contribution.users.${username}.modules or []);

  profileHomeModules = nativeClass: username: tag: let
    selected = profile nativeClass tag;
    overlay = configurations.perTag.${tag} or {};
  in
    selected.home ++ (overlay.users.${username}.modules or []);
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
      classNames = lib.unique [class.nativeClass host.class];
      rootProfiles = map (tag: profile class.nativeClass tag) configurations.tags;
      hostProfiles = map (tag: profile class.nativeClass tag) host.tags;
      baseContributions =
        [configurations.shared]
        ++ map (className: configurations.perClass.${className} or {}) classNames;
      homeClassLayer = configurations.perClass.home or {};
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
      users =
        lib.mapAttrs (username: hostLayer: let
          user = configurations.users.${username};
          baseUserModules =
            user.modules
            ++ (homeClassLayer.homeModules or [])
            ++ (homeClassLayer.users.${username}.modules or [])
            ++ lib.concatMap (profileHomeModules class.nativeClass username) configurations.tags
            ++ lib.concatMap (homeContributions username) (lib.tail baseContributions)
            ++ lib.concatMap (profileHomeModules class.nativeClass username) user.tags;
          taggedUserModules =
            lib.concatMap (profileHomeModules class.nativeClass username) host.tags
            ++ lib.concatMap (profileHomeModules class.nativeClass username) hostLayer.tags;
        in {
          inherit (hostLayer) outputName;
          tags = user.tags ++ hostLayer.tags;
          baseModules = baseUserModules;
          tagModules = taggedUserModules;
          hostModules = hostLayer.modules;
          modules = baseUserModules ++ taggedUserModules ++ hostLayer.modules;
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
          metadata = configurations.perTag.${tag}.metadata or {};
        }) (configurations.tags ++ host.tags);
        host = host.metadata;
      };
    }))
  ];
}
