args @ {config, ...}: let
  inherit (config.wsl) defaultUser wslConf;
  cdrive = "${wslConf.automount.root}/c";
  user = args.defaultUser or defaultUser;
in {
  fileSystems."/home/.ro/${user}" = {
    depends = [
      "${cdrive}"
    ];

    device = "${cdrive}/Users/${user}";
    fsType = "none";
    options = [
      "ro"
      "bind"
      "X-mount.mkdir"
    ];
  };

  fileSystems."/home/${user}" = {
    depends = [
      "/home/.ro/${user}"
    ];

    device = "overlay";
    fsType = "overlay";
    options = [
      "lowerdir=/home/.ro/${user}"
      "upperdir=/home/.rw/${user}"
      "workdir=/home/.rw/workdir-${user}"
      "X-mount.mkdir"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /home/.rw 			755 root    root  - -"
    "d /home/.rw/${user} 		755 ${user} users - -"
    "d /home/.rw/workdir-${user} 	755 ${user} users - -"
  ];
}
