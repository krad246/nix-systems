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
        username = "standalone";
        homeDirectory = "/home/standalone";
      }
      else {
        username = builtins.getEnv "USER";
        homeDirectory = builtins.getEnv "HOME";
      }
    );
}
