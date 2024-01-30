{pkgs, ...}: {
  imports = [../cachix.nix];
  home.packages = with pkgs; [cachix];
}
