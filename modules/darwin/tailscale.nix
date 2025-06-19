{
  withSystem,
  pkgs,
  ...
}: {
  # homebrew.casks = ["tailscale"];
  services.tailscale = {
    enable = true;
    package = withSystem pkgs.stdenv.system ({inputs', ...}: inputs'.nixpkgs-unstable.legacyPackages.tailscale);
  };
}
