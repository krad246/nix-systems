{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.hercules-ci-agent.darwinModules.agent-profile];
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
    enable = lib.modules.mkDefault true;
    settings = {
      concurrentTasks = lib.modules.mkDefault "auto";
      nixVerbosity = "Warn";
    };
  };
}
