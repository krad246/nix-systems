{
  ezModules,
  config,
  ...
}: {
  specialisation = {
    ${config.networking.hostName} = {
      configuration = {
        imports = [ezModules.flatpak] ++ [ezModules.steam];
      };
    };
  };
}
