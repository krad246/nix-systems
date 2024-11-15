{self, ...}: {
  inputs',
  self',
  pkgs,
  ...
}: let
  inherit (pkgs) lib;

  # Create a justfile fragment from a:
  # 1. documentation comment
  # 2. recipe group
  # 3. justfile recipe (mandatory)
  mkJustRecipe = {
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
    group,
    recipes,
    ...
  }:
    lib.attrsets.mapAttrs (_key: recipe: let
      # slap the 'group' field on each recipe attrset
      args =
        recipe
        // {inherit group;};
    in
      mkJustRecipe args)
    recipes;
in
  # Git commands
  mkJustRecipeGroup {
    group = "git";

    recipes = {
      git = {
        comment = "Wraps `git`. Pass arguments as normal.";
        justfile = ''
          [no-exit-message]
          git *ARGS:
              ${lib.getExe pkgs.git} {{ ARGS }}
        '';
      };

      add = {
        comment = "Equivalent to `git add -u` by default, unless other args are passed.";
        justfile = ''
          add +ARGS="-u": (git "add" "--chmod=+x" ARGS)
        '';
      };

      commit = {
        comment = "Equivalent to `git add -u` followed by `git commit --dry-run`, unless other args are passed.";
        justfile = ''
          commit +ARGS="--dry-run": (add "-u") (git "commit" ARGS)
        '';
      };

      amend = {
        comment = "Equivalent to `git add -u` followed by `git commit --amend`, with other args passed to its invocation.";
        justfile = ''
          amend +ARGS="--dry-run": (add "-u") (commit "--amend" ARGS)
        '';
      };
    };
  }
  # nixos-rebuild and other system management tools.
  // mkJustRecipeGroup {
    group = "system";

    recipes =
      (lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        # Add a wrapper around nixos-rebuild to devShell instances if we're on Linux
        nixos-rebuild = {
          comment = "Wraps `nixos-rebuild`.";
          justfile = ''
            [linux]
            @nixos-rebuild *ARGS: (add)
              #!${lib.meta.getExe pkgs.bash}
              ${lib.meta.getExe pkgs.nixos-rebuild} \
                --option experimental-features 'nix-command flakes' \
                --option inputs-from ${self} \
                --option accept-flake-config true \
                --option builders-use-substitutes true \
                --option keep-going true \
                --option preallocate-contents true \
                --flake ${self} \
                --use-remote-sudo \
                {{ ARGS }}
          '';
        };

        switch = {
          comment = "Recreate the lockfile and run `nixos-rebuild switch` to switch the system derivation.";
          justfile = ''
            switch *ARGS: (nix "flake" "lock") (nixos-rebuild "switch" ARGS)
          '';
        };
      })
      // (lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
        # Add a wrapper around nixos-rebuild to devShell instances if we're on Darwin
        darwin-rebuild = {
          comment = "Wraps `darwin-rebuild`.";
          justfile = ''
            [macos]
            @darwin-rebuild *ARGS: (add)
              #!${lib.meta.getExe pkgs.bash}
              ${lib.meta.getExe' inputs'.darwin.packages.darwin-rebuild "darwin-rebuild"} \
                --option experimental-features 'nix-command flakes' \
                --option accept-flake-config true \
                --option keep-going true \
                --option preallocate-contents true \
                --flake ${self} \
                {{ ARGS }}
          '';
        };

        switch = {
          comment = "Recreate the lockfile and run `darwin-rebuild switch` to switch the system derivation.";
          justfile = ''
            switch *ARGS: (nix "flake" "lock") (darwin-rebuild "switch" ARGS)
          '';
        };
      })
      // {
        # Home configs work on all *nix systems
        home-manager = {
          comment = "Wraps `home-manager`.";

          justfile = ''
            [unix]
            @home-manager *ARGS: (add)
              #!${lib.meta.getExe pkgs.bash}
              ${lib.meta.getExe pkgs.home-manager} \
                --option experimental-features 'nix-command flakes' \
                --option inputs-from ${self} \
                --option accept-flake-config true \
                --option keep-going true \
                --option preallocate-contents true \
                --flake ${self} \
                -b bak \
                {{ ARGS }}
          '';
        };

        upgrade = {
          comment = "Update the flake and reload the system derivation.";
          justfile = ''
            upgrade *ARGS: && (switch ARGS)
              -exec just nix flake update
          '';
        };
      };
  }
  # Helper command aliases
  // mkJustRecipeGroup {
    group = "nix";

    recipes = {
      build = {
        comment = "Wraps `nix build`.";
        justfile = ''
          build *ARGS: (add) (nix "build" ARGS)
        '';
      };

      run = {
        comment = "Wraps `nix run`.";
        justfile = ''
          run *ARGS: (add) (nix "run" ARGS)
        '';
      };

      # nix works on all *nix systems
      nix = {
        comment = "Wraps `nix`. Pass arguments as normal.";
        justfile = ''
          [unix]
          @nix VERB *ARGS: (add)
            #!${lib.meta.getExe pkgs.bash}
            ${lib.meta.getExe pkgs.nixFlakes} {{ VERB }} \
              --option experimental-features 'nix-command flakes' \
              --option inputs-from ${self} \
              --option accept-flake-config true \
              --option builders-use-substitutes true \
              --option keep-going true \
              --option preallocate-contents true \
              {{ ARGS }}
        '';
      };
    };
  }
  // mkJustRecipeGroup {
    group = "dev";
    recipes = {
      container = {
        comment = "Container commands. Syntax: `just container ARGS`";
        justfile = ''
          container *ARGS:
            ${lib.getExe pkgs.gnumake} -f ${self'.packages.makefile} {{ prepend("container-", ARGS) }}
        '';
      };

      devour-flake = {
        comment = "Build all outputs in the repository.";
        justfile = ''
          devour-flake *ARGS: (run "${self}#devour-flake -- " ARGS)
        '';
      };

      fmt = {
        comment = "Format the repository.";
        justfile = ''
          fmt: add
            treefmt
        '';
      };
    };
  }
  // mkJustRecipeGroup {
    group = "misc";
    recipes = {
      rekey = {
        comment = "Run `agenix --rekey`.";
        justfile = ''
          rekey *ARGS:
            ${lib.getExe' pkgs.coreutils "env"} --chdir "$FLAKE_ROOT/modules/generic/secrets" \
              ${lib.getExe' inputs'.agenix.packages.default "agenix"} -r {{ ARGS }}
        '';
      };

      dd = {
        comment = "Write flake output to stdout. Must be piped to a file. Syntax: `just dd ARGS`.";
        justfile = ''
          dd *ARGS: (build ARGS)
            ${lib.getExe pkgs.pv} < "$(${lib.getExe' pkgs.findutils "find"} -L {{ ARGS }} -type f)"
        '';
      };
    };
  }
