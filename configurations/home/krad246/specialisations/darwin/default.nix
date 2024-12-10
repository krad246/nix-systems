{
  lib,
  pkgs,
  ...
}: {
  disabledModules = [../linux/generic-linux.nix];
  imports = [./darwin.nix];

  specialisation.default = lib.modules.mkIf pkgs.stdenv.isDarwin {
    configuration = import ./darwin.nix;
  };
}
