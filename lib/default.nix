{lib}: {
  krad246 = {
    attrsets = import ./attrsets.nix {inherit lib;};
    cli = import ./cli.nix {inherit lib;};
    fileset = import ./fileset.nix {inherit lib;};
    strings = import ./strings.nix {inherit lib;};
  };
}
