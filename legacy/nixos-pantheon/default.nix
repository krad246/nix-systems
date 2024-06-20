args: let
  inputs = args.inputs or {};
  disko = inputs.disko.nixosModules.disko or import ./fetch-disko.nix;
in {
  imports = [disko] ++ [./disko-config.nix ./initial-configuration.nix];
}
