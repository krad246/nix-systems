rec {
  default.configuration = windex.configuration;
  windex.configuration = import ./windex.nix;
}
