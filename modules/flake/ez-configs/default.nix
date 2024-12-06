{
  withSystem,
  importApply,
  self,
  inputs,
  ...
}: {
  # importApply basically curries / partially applies some extra arguments to the existing argument
  # list of a module
  flakeModule = importApply ./flake-module.nix {inherit withSystem importApply inputs self;};
}
