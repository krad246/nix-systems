{lib}: {
  stem = path:
    lib.strings.nameFromURL (builtins.baseNameOf path) ".";
}
