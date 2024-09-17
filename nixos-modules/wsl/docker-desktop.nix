{
  lib,
  pkgs,
  ...
}: {
  wsl = {
    # Enable integration with Docker Desktop (needs to be installed)
    docker-desktop.enable = true;

    extraBin = with pkgs; [
      # Binaries for Docker Desktop wsl-distro-proxy
      {src = lib.getExe' pkgs.coreutils "mkdir";}
      {src = lib.getExe' pkgs.coreutils "cat";}
      {src = lib.getExe' pkgs.coreutils "whoami";}
      {src = lib.getExe' pkgs.coreutils "ls";}
      {src = lib.getExe' pkgs.coreutils "addgroup";}
      {src = lib.getExe' pkgs.coreutils "groupadd";}
      {src = lib.getExe' pkgs.coreutils "usermod";}
    ];
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };
}
