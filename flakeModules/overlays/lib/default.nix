final: prev: {
  krad246 = {
    attrsets = import ./attrsets.nix final prev;
    cli = import ./cli.nix final prev;
    fileset = import ./fileset.nix final prev;
    strings = import ./strings.nix final prev;
  };
}
