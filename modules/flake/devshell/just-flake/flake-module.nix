# outer / 'flake' scope
{
  importApply,
  self,
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
  justfile-system = importApply ./commands/system.nix {inherit mkJustRecipeGroup;};
in {
  imports = [justfile-dev justfile-git justfile-misc justfile-system];

  # export the flake modules we loaded to this context for user consumption
  flake = rec {
    flakeModules = {
      inherit
        justfile-dev
        justfile-git
        justfile-misc
        justfile-system
        ;
    };

    modules.flake = flakeModules;
  };

  perSystem = {pkgs, ...}: {
    # set up devshell commands
    just-flake.features = let
      inherit (pkgs) lib;

      inputArg = lib.strings.concatStringsSep " " ["--option" "inputs-from" "$FLAKE_ROOT"];
    in
      # Helper command aliases
      mkJustRecipeGroup {
        inherit lib;
        group = "nix";

        recipes = {
          nix = {
            comment = "Wraps `nix`. Pass arguments as normal.";
            justfile = ''
              [unix]
              @nix VERB *ARGS: (add)
                #!${lib.meta.getExe pkgs.bash}
                ${lib.meta.getExe pkgs.nixVersions.stable} {{ VERB }} \
                  --option experimental-features 'nix-command flakes' \
                  ${inputArg} \
                  --option accept-flake-config true \
                  --option builders-use-substitutes true \
                  --option keep-going true \
                  --option preallocate-contents true \
                  {{ ARGS }}
            '';
          };

          build = {
            comment = "Wraps `nix build`.";
            justfile = ''
              build *ARGS: (add) (nix "build" ARGS)
            '';
          };

          develop = {
            comment = "Wraps `nix develop`.";
            justfile = ''
              develop *ARGS: (add) (nix "develop" ARGS)
            '';
          };

          flake = {
            comment = "Wraps `nix flake`.";
            justfile = ''
              flake *ARGS: (fmt) (nix "flake" ARGS)
            '';
          };

          run = {
            comment = "Wraps `nix run`.";
            justfile = ''
              run *ARGS: (add) (nix "run" ARGS)
            '';
          };

          search = {
            comment = "Wraps `nix search`.";
            justfile = ''
              search *ARGS: (add) (nix "search" ARGS)
            '';
          };

          shell = {
            comment = "Wraps `nix shell`.";
            justfile = ''
              shell *ARGS: (add) (nix "shell" ARGS)
            '';
          };
        };
      }
      // mkJustRecipeGroup {
        inherit lib;
        group = "flake";
        recipes = {
          show = {
            comment = "Wraps `nix flake show`.";
            justfile = ''
              show *ARGS: (flake "show" ARGS)
            '';
          };

          check = {
            comment = "Wraps `nix flake check`.";
            justfile = ''
              check *ARGS: (flake "check" ARGS)
            '';
          };

          repl = {
            comment = "Wraps `nix repl .`";
            justfile = ''
              repl *ARGS: (nix "repl" "--file" "$FLAKE_ROOT")
            '';
          };
        };
      };
  };
}
