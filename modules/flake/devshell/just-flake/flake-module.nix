# outer / 'flake' scope
{
  importApply,
  inputs,
  self,
  ...
}: let
  justfile-git = importApply ./commands/git.nix {};
  justfile-nix = importApply ./commands/nix-flakes.nix {inherit self;};

  justfile = {
    imports =
      [inputs.just-flake.flakeModule]
      ++ [
        justfile-git
        justfile-nix
      ];
  };
in {
  imports = [
    inputs.just-flake.flakeModule
    justfile-git
    justfile-nix
  ];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      inherit justfile;
    };

    modules.flake = flakeModules;
  };
}
