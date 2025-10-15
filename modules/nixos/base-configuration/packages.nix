{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [bashmount];
  };
}
