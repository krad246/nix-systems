{
  config,
  lib,
  ...
}: {
  options.dendritic.internal.systemDeclarations = lib.mkOption {
    type = lib.types.attrsOf lib.types.raw;
    readOnly = true;
    internal = true;
  };

  config.dendritic.internal.systemDeclarations = lib.pipe config.dendritic.configurations.hosts [
    (lib.filterAttrs (_: host: host.enable))
    (lib.mapAttrs (hostName: host: let
      class = config.dendritic.configurations.classes.${host.class} or (throw "dendritic.configurations: host ${hostName} refers to unknown class ${host.class}");
      classNames = lib.unique [class.nativeClass host.class];
      rootTagLayers = map (tag: config.dendritic.configurations.perTag.${tag} or {}) config.dendritic.configurations.tags;
      baseLayers =
        [config.dendritic.configurations.shared]
        ++ rootTagLayers
        ++ map (className: config.dendritic.configurations.perClass.${className} or {}) classNames;
      tagLayers = map (tag: config.dendritic.configurations.perTag.${tag} or {}) host.tags;
      baseModules = lib.concatMap (layer: layer.modules or []) baseLayers;
      tagModules = lib.concatMap (layer: layer.modules or []) tagLayers;
      hostModules = host.modules;
      selectedUsers = lib.filterAttrs (username: _: config.dendritic.configurations.users ? ${username} && config.dendritic.configurations.users.${username}.enable) host.users;
    in {
      inherit (host) enable outputName hostPlatforms buildPlatform crossCompile variants;
      tags = config.dendritic.configurations.tags ++ host.tags;
      inherit (host) class;
      inherit (class) nativeClass;
      inherit baseModules tagModules hostModules;
      modules = baseModules ++ tagModules ++ hostModules;
      users =
        lib.mapAttrs (username: hostLayer: let
          user = config.dendritic.configurations.users.${username};
          userTagLayers = map (tag: config.dendritic.configurations.perTag.${tag} or {}) user.tags;
          hostUserTagLayers = map (tag: config.dendritic.configurations.perTag.${tag} or {}) hostLayer.tags;
          baseModules =
            user.modules
            ++ lib.concatMap (layer: (layer.users.${username}.modules or [])) baseLayers
            ++ lib.concatMap (layer: (layer.users.${username}.modules or [])) userTagLayers;
          tagModules =
            lib.concatMap (layer: (layer.users.${username}.modules or [])) tagLayers
            ++ lib.concatMap (layer: (layer.users.${username}.modules or [])) hostUserTagLayers;
          hostModules = hostLayer.modules;
        in {
          inherit (hostLayer) outputName;
          tags = user.tags ++ hostLayer.tags;
          inherit baseModules tagModules hostModules;
          modules = baseModules ++ tagModules ++ hostModules;
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
          metadata = config.dendritic.configurations.perTag.${tag}.metadata or {};
        }) (config.dendritic.configurations.tags ++ host.tags);
        host = host.metadata;
      };
    }))
  ];
}
