{
  lib,
  pkgs,
  ...
}: {
  specialisation = lib.mkIf pkgs.stdenv.isDarwin {
    darwin.configuration = import ./darwin.nix;
  };
}
