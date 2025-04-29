{
  self,
  lib,
  ...
}: {
  imports = [
    self.homeModules.helix
  ];

  home = {
    stateVersion = lib.trivial.release;
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";
  };
}
