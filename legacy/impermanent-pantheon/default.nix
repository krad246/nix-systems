args: let
  inputs = args.inputs or {};
  disko = inputs.disko.nixosModules.disko or import ./fetch-disko.nix;
  impermanence = inputs.impermanence.nixosModules.impermanence or import ./fetch-impermanence.nix;
in {
  imports = [disko] ++ [./disko-config.nix ./initial-configuration.nix] ++ [impermanence];
}
