{
  inputs',
  self',
  pkgs,
  ...
}: let
  inherit (pkgs) lib;

  mkJustRecipe = {
    justfile,
    comment ? null,
    group ? null,
    ...
  }: {
    enable = true;
    justfile = ''
      ${lib.strings.optionalString (comment != null) "#${comment}"}
      ${lib.strings.optionalString (group != null) "[group('${group}')]"}
      ${justfile}
    '';
  };

  mkJustRecipeGroup = {
    group,
    recipes,
    ...
  }:
    lib.attrsets.mapAttrs (_key: recipe: let
      args =
        recipe
        // {inherit group;};
    in
      mkJustRecipe args)
    recipes;

  # Compose a simple just target from the name of the incoming derivation
  mkSystemRecipe = {
    drv,
    pname ? lib.getName drv,
    os,
    extraArgs,
    ...
  }: ''
    [${os}]
    @${pname} *ARGS: (add)
      #!${lib.meta.getExe pkgs.bash}
      ${lib.meta.getExe' drv pname} \
        ${lib.strings.concatStringsSep " \\\n    " extraArgs} {{ ARGS }}
  '';

  # Extra args to tack onto the invocation wrappers below...
  builderArgs = [
    "--option experimental-features 'nix-command flakes'"
    "--option inputs-from $FLAKE_ROOT"
    "--option accept-flake-config true"
    "--option builders-use-substitutes true"
    "--option keep-going true"
    "--option preallocate-contents true"
  ];
in
  {
    treefmt = {
      enable = true;
    };
  }
  # Git commands
  // mkJustRecipeGroup {
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
          justfile = mkSystemRecipe {
            drv = pkgs.nixos-rebuild;
            os = "linux";
            extraArgs =
              builderArgs
              ++ [
                "--use-remote-sudo"
                "--flake $FLAKE_ROOT"
              ];
          };
        };
      })
      // (lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
        # Add a wrapper around nixos-rebuild to devShell instances if we're on Darwin
        darwin-rebuild = {
          comment = "Wraps `darwin-rebuild`.";
          justfile = mkSystemRecipe {
            drv = inputs'.darwin.packages.darwin-rebuild;
            os = "macos";
            extraArgs =
              builderArgs
              ++ [
                "--flake $FLAKE_ROOT"
              ];
          };
        };
      })
      // {
        # Home configs work on all *nix systems
        home-manager = {
          comment = "Wraps `home-manager`.";

          justfile = mkSystemRecipe {
            drv = pkgs.home-manager;
            os = "unix";
            extraArgs =
              builderArgs
              ++ [
                "-b bak"
                "--flake $FLAKE_ROOT"
              ];
          };
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
        justfile = mkSystemRecipe {
          drv = pkgs.nixFlakes;
          os = "unix";
          extraArgs = builderArgs;
        };
      };
    };
  }
  // {
    container = {
      justfile = ''
        [private]
        _make *ARGS:
          ${lib.getExe pkgs.gnumake} -f ${self'.packages.makefile} {{ ARGS }}

        container *VERBS: (_make prepend("container-", VERBS))
      '';
    };

    devour-flake = {
      justfile = ''devour-flake *ARGS: (run "$FLAKE_ROOT#devour-flake -- " ARGS)'';
    };
  }
  // {
    rekey = {
      enable = true;
      justfile = ''
        rekey *ARGS:
          ${lib.getExe' pkgs.coreutils "env"} --chdir "$FLAKE_ROOT/common/secrets" \
            ${lib.getExe' inputs'.agenix.packages.default "agenix"} -r {{ ARGS }}
      '';
    };

    dd = {
      enable = true;
      justfile = ''
        dd +ARGS: (build ARGS)
          ${lib.getExe pkgs.pv} < \
            "$(${lib.getExe' pkgs.findutils "find"} \
              -L {{ ARGS }} -type f)"
      '';
    };
  }
