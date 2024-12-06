{
  lib,
  pkgs,
  ...
}: {
  specialisation = lib.modules.mkIf pkgs.stdenv.isDarwin {
    darwin.configuration = import ./darwin.nix;
  };
}
