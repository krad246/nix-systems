args @ {
  lib,
  config,
  ...
}: let
  hercules-ci-agent = lib.attrsets.attrByPath ["inputs" "hercules-ci-agent"] (builtins.getFlake "github:hercules-ci/hercules-ci-agent/hercules-ci-agent-0.10.5") args;
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
  systemd.services = lib.modules.mkIf config.services.hercules-ci-agent.enable {
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
