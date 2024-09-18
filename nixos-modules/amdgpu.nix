{pkgs, ...}: {
  boot.initrd.kernelModules = ["amdgpu"];
  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];
  };
  hardware.opengl = {
    extraPackages = with pkgs; [amdvlk];
    extraPackages32 = with pkgs; [driversi686Linux.amdvlk];
  };
}
