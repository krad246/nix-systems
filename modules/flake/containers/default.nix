{
  importApply,
  self,
  ...
}: {
  # importApply basically curries / partially applies some extra arguments to the existing argument
  # list of a module
  flakeModule = importApply ./flake-module.nix {inherit importApply self;};
}
