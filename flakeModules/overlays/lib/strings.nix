_final: prev: {
  stem = path:
    prev.strings.nameFromURL (builtins.baseNameOf path) ".";
}
