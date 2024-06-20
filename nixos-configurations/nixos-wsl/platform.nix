_: {
  fileSystems."/c" = {
    depends = [
      "/mnt/c"
    ];

    device = "/mnt/c";
    fsType = "none";
    options = [
      "bind"
      "X-mount.mkdir"
    ];
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
