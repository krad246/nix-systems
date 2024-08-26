{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      safe-rm
    ];
  };
}
