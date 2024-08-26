{lib, ...}:
lib.attrsets.optionalAttrs lib.trivial.inPureEvalMode {
  imports = [./agenix.nix ./cachix.nix ./gh.nix];
}
