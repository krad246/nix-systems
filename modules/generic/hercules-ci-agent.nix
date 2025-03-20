{
  nix.settings = {
    substituters = [
      "https://hercules-ci.cachix.org"
    ];
    trusted-substituters = [
      "https://hercules-ci.cachix.org"
    ];
    trusted-public-keys = [
      "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
    ];
  };

  services.hercules-ci-agent = {
    enable = true;
    settings = {
      concurrentTasks = "auto";
      nixVerbosity = "Warn";
    };
  };

  environment.variables.NIX_REMOTE = "daemon";
}
