_: let
  disko = import ./fetch-disko.nix;
  impermanence = import ./fetch-impermanence.nix;
in {
  imports =
    [disko ./disko-config.nix]
    ++ [impermanence];

  fileSystems."/nix/persist".neededForBoot = true;
}
