{
  lib,
  pkgs,
  ...
}: {
  disabledModules = [../linux];

  specialisation.default = lib.modules.mkIf pkgs.stdenv.isDarwin {
    configuration = import ./darwin.nix;
  };
}
