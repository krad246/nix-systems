args @ {importApply, ...}: {
  flakeModule = importApply ./flake-module.nix args;
}
