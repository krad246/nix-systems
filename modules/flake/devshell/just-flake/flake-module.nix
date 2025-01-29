# outer / 'flake' scope
outer @ {
  importApply,
  inputs,
  self,
  ...
}: let
  # hijacking the nixos specialArgs convention to pass some custom functions down.
  specialArgs = rec {
    # Create a justfile fragment from a:
    # 0. (also need support lib)
    # 1. documentation comment
    # 2. recipe group
    # 3. justfile recipe (mandatory)
    mkJustRecipe = inner @ {
      lib,
      justfile,
      enable ? true,
      comment ? null,
      group ? null,
      ...
    }: let
      inherit (inner.lib) strings;
    in {
      inherit enable;

      # format the comment and group above the justfile so that
      # the writer of the justfile can put more modifiers on the recipe they define
      justfile = ''
        ${strings.optionalString (comment != null) "# ${comment}"}
        ${strings.optionalString (group != null) "[group('${group}')]"}
        ${justfile}
      '';
    };

    # create a 'group' of recipes where the user can pass a list of recipes to bind to a given group
    mkJustRecipeGroup = inner @ {
      lib,
      group,
      recipes,
      ...
    }: let
      inherit (inner.lib) attrsets;
    in
      attrsets.mapAttrs (_key: recipe: mkJustRecipe (recipe // {inherit (inner) lib group;}))
      recipes;

    inherit (outer.specialArgs) nixArgs;
  };

  justfile-dev = importApply ./commands/dev.nix {
    inherit self specialArgs;
  };

  justfile-git = importApply ./commands/git.nix {
    inherit self specialArgs;
  };

  justfile-misc = importApply ./commands/misc.nix {
    inherit self specialArgs;
  };

  justfile-nix = importApply ./commands/nix-flakes.nix {
    inherit self specialArgs;
  };

  justfile-home = importApply ./commands/home.nix {
    inherit self specialArgs;
  };

  justfile-system = importApply ./commands/system.nix {
    inherit self specialArgs;
  };
in {
  imports =
    [inputs.just-flake.flakeModule]
    ++ [
      justfile-git
    ];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      inherit
        justfile-dev
        justfile-git
        justfile-misc
        justfile-system
        justfile-nix
        justfile-home
        ;
    };

    modules.flake = flakeModules;
  };
}
