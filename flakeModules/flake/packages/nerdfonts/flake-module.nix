_: {
  perSystem = {pkgs, ...}: {
    packages.term-fonts = pkgs.callPackage ./term-fonts.nix {};
  };
}
