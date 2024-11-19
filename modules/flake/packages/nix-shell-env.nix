{
  pkgs,
  targetPkgs ? (_tpkgs: []),
  inputsFrom ? [],
  shellHook ? "",
  ...
}:
pkgs.mkShell {
  packages = targetPkgs pkgs;
  inherit inputsFrom;
  inherit shellHook;
}
