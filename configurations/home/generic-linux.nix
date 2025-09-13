{
  self,
  lib,
  ...
}: {
  imports = [
    self.homeModules.base-home
  ];

  home =
    {}
    // (
      if lib.trivial.inPureEvalMode
      then {
        username = "generic-linux";
        homeDirectory = "/home/generic-linux";
      }
      else {
        username = builtins.getEnv "USER";
        homeDirectory = builtins.getEnv "HOME";
      }
    );
}
