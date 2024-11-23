# outer / 'flake' scope
{
  importApply,
  self,
  inputs,
  ...
}: let
  # Create a justfile fragment from a:
  # 0. (also need support lib)
  # 1. documentation comment
  # 2. recipe group
  # 3. justfile recipe (mandatory)
  mkJustRecipe = {
    lib,
    justfile,
    comment ? null,
    group ? null,
    ...
  }: {
    enable = true;

    # format the comment and group above the justfile so that
    # the writer of the justfile can put more modifiers on the recipe they define
    justfile = ''
      ${lib.strings.optionalString (comment != null) "#${comment}"}
      ${lib.strings.optionalString (group != null) "[group('${group}')]"}
      ${justfile}
    '';
  };

  # create a 'group' of recipes where the user can pass a list of recipes to bind to a given group
  mkJustRecipeGroup = {
    lib,
    group,
    recipes,
    ...
  }:
    lib.attrsets.mapAttrs (_key: recipe: mkJustRecipe (recipe // {inherit lib group;}))
    recipes;

  justfile-dev = importApply ./commands/dev.nix {inherit mkJustRecipeGroup self;};
  justfile-git = importApply ./commands/git.nix {inherit mkJustRecipeGroup;};
  justfile-misc = importApply ./commands/misc.nix {inherit mkJustRecipeGroup;};
  justfile-nix = importApply ./commands/nix {inherit mkJustRecipeGroup;};
  justfile-system = importApply ./commands/system.nix {inherit mkJustRecipeGroup self;};
in {
  imports = [inputs.just-flake.flakeModule] ++ [justfile-dev justfile-git justfile-misc justfile-system justfile-nix];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      inherit
        justfile-dev
        justfile-git
        justfile-misc
        justfile-system
        justfile-nix
        ;
    };

    modules.flake = flakeModules;
  };
}
