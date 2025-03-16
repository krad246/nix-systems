# outer / 'flake' scope
{inputs, ...}: let
  justfile-git = ./commands/git.nix;
  justfile-nix = ./commands/nix-flakes.nix;

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
