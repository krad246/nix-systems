{lib, ...}: {
  nix = {
    daemonIOLowPriority = lib.modules.mkDefault true;
    daemonProcessType = lib.modules.mkDefault "Adaptive";

    settings = {
      auto-optimise-store = false;
      extra-sandbox-paths = ["/nix/store"];
      auto-allocate-uids = false;
    };
  };

  environment.variables.NIX_REMOTE = "daemon";
}
