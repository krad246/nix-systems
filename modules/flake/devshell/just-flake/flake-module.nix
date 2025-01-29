# outer / 'flake' scope
args @ {
  importApply,
  inputs,
  ...
}: let
  justfile-git = importApply ./commands/git.nix args;
  justfile-nix = importApply ./commands/nix-flakes.nix args;

  justfile = {
    imports =
      [inputs.just-flake.flakeModule]
      ++ [
        justfile-git
        justfile-nix
      ];
  };
in {
  imports = [justfile];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      inherit justfile-git;
      inherit justfile-nix;
      inherit justfile;
    };

    modules.flake = flakeModules;
  };
}
