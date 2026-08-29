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
    (lib.mapAttrs (_hostName: host: {
      inherit (host) enable class tags hostPlatforms buildPlatform crossCompile variants;
      modules =
        lib.pipe (
          [
            config.dendritic.configurations.shared
            (config.dendritic.configurations.perClass.${host.class} or {})
          ]
          ++ map (tag: config.dendritic.configurations.perTag.${tag} or {}) host.tags
          ++ [host]
        ) [
          (map (layer: layer.modules or []))
          lib.concatLists
        ];
      users =
        lib.mapAttrs (username: layer: {
          modules = config.dendritic.configurations.users.${username}.modules ++ layer.modules;
        })
        host.users;
    }))
  ];
}
