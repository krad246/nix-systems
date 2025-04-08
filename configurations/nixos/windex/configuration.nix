outer @ {
  inputs,
  self,
  config,
  lib,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports =
    [nixos-generators.nixosModules.all-formats]
    ++ (with self.nixosModules; [
      base-configuration
      wsl
    ]);

  programs.dconf.enable = false;

  # Doesn't make sense on WSL's network stack
  systemd.services.NetworkManager-wait-online.enable = false;

  # disable all formats other than the tarball format
  formats = lib.modules.mkForce {
    tarball = config.system.build.tarballBuilder;
  };

  formatConfigs = {
    tarball = {
      formatAttr = "tarballBuilder";
    };
  };

  # NixOS is going to get the first user ID
  # It'll own this distro as the default user
  wsl.defaultUser = "keerad";

  # Shared home with Windows; handled via overlayFS mount
  users.users.keerad = {
    uid = lib.modules.mkForce 1001;
    isNormalUser = true;
    home = "/home/keerad";
    description = "Keerthi Radhakrishnan";
    initialHashedPassword = "";
    extraGroups = ["wheel" "NetworkManager" "docker" "kvm"];
  };

  # Linux user
  users.users.krad246 = {
    uid = 1002;
    isNormalUser = true;
    home = "/home/krad246";
    description = "Keerthi Radhakrishnan";
    extraGroups = ["wheel" "NetworkManager" "docker" "kvm"];
  };

  home-manager.sharedModules = [
    (inner @ {
      config,
      lib,
      pkgs,
      ...
    }: {
      systemd.user.mounts = {
        "home-${inner.config.home.username}-.config-Code-User" = {
          Unit = {
            Description = "Mount VSCode config directory from Windows host to WSL.";
          };
          Install.WantedBy = ["default.target"];
          Mount = {
            ExecSearchPath = lib.strings.makeBinPath [pkgs.bindfs];
            What = "${outer.config.wsl.wslConf.automount.root}/c/Users/${outer.config.wsl.defaultUser}/AppData/Roaming/Code/User";
            Where = "${inner.config.xdg.configHome}/Code/User";
            Type = "fuse.bindfs";
            Options = "perms=0777,mirror-only=${inner.config.home.username}";
          };
        };
      };
    })

    ({lib, ...}: {
      # default specialisation is automatically switched to,
      # so overriding it from generic-linux disables it.
      specialisation = rec {
        default.configuration = lib.modules.mkForce {};
      };
    })
  ];

  services.tailscale.enable = true;

  # required to deal with a DNS fight issue with tailscale.
  wsl.wslConf.network.generateResolvConf = false;

  # services.resolved.enable = true;

  networking.nameservers = [
    "100.100.100.100" # tailscale base
    "10.255.255.254" # host nameserver from WSL bridge
  ];

  networking.search = [
    "tailb53085.ts.net" # tailnet
    "ad.global"
  ];

  nix.settings.max-substitution-jobs = 128;

  # mount an overlayFS over the /etc dir
  boot.initrd.systemd.enable = true;
  system.etc.overlay = {
    enable = true;
    mutable = true;
  };
}
