_: let
  disko = import ./fetch-disko.nix;
in {
  imports = [disko];
}
