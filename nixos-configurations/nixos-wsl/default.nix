{ezModules, ...}: {
  imports = [ezModules.nixos-cli ezModules.wsl] ++ [./platform.nix];

  nixpkgs.hostPlatform = "x86_64-linux";
}
