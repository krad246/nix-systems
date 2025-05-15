args @ {lib, ...}: let
  hercules-ci-agent = lib.attrsets.attrByPath ["inputs" "hercules-ci-agent"] (builtins.getFlake "github:hercules-ci/hercules-ci-agent/6e1d58c59b63574e9f033bb9dace7a3f42a8413a") args;
in {
  imports = [
    hercules-ci-agent.nixosModules.agent-profile
  ];

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

  services.hercules-ci-agents."" = {
    settings = {
      concurrentTasks = lib.modules.mkDefault "auto";
      nixVerbosity = "Warn";
    };
  };

  # prevent the associated hercules CI agent systemd service from blowing itself up when
  # running a deployment on the same machine in the effects sandbox.
  systemd.services = {
    hercules-ci-agent = {
      enable = true;
      restartIfChanged = false;
      reloadIfChanged = false;
      stopIfChanged = false;
    };

    hercules-ci-agent-restarter = {
      enable = true;
      restartIfChanged = false;
      reloadIfChanged = false;
      stopIfChanged = false;
    };
  };
}
