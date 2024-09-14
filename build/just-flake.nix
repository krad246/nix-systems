{self, ...}: {
  perSystem = {
    lib,
    pkgs,
    inputs',
    ...
  }: let
    # Compose a simple just target from the name of the incoming derivation
    mkJustRecipe = args @ {
      drv,
      pname ? lib.getName drv,
      os,
      extraArgs,
      ...
    }: let
      # Conditionally include an alias line if an alias is passd
      maybeString = pred: val: lib.strings.optionalString pred val;
      mkAlias = alias: pname: "alias ${alias} := ${pname}";
    in ''
      # `${pname}` related subcommands. Syntax: just ${pname} <subcommand>
      [${os}]
      @${pname} *ARGS:
        #!${lib.meta.getExe pkgs.bash}
        ${lib.meta.getExe' drv pname} ${lib.strings.concatStringsSep " " extraArgs} {{ ARGS }}

      ${maybeString (args ? alias) (mkAlias args.alias pname)}
    '';
  in {
    just-flake.features = let
      # Extra args to tack onto the invocation wrappers below...
      flakeRoot = self;
      commonArgs = [
        "--option experimental-features 'nix-command flakes'"
        "--option inputs-from ${flakeRoot}"
      ];
      flakeArgs = ["--flake ${flakeRoot}"];
      builderArgs = commonArgs ++ flakeArgs;
    in {
      treefmt = {
        enable = true;
      };

      # Add a wrapper around nixos-rebuild to devShell instances if we're on Linux
      nixos-rebuild = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        enable = true;
        justfile = mkJustRecipe {
          drv = pkgs.nixos-rebuild;
          os = "linux";
          extraArgs = builderArgs ++ ["--use-remote-sudo" "--fallback"];
          alias = "os";
        };
      };

      # Add a wrapper around nixos-rebuild to devShell instances if we're on Darwin
      darwin-rebuild = lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
        enable = true;
        justfile = mkJustRecipe {
          drv = inputs'.darwin.packages.darwin-rebuild;
          os = "macos";
          extraArgs = builderArgs ++ ["--fallback"];
          alias = "os";
        };
      };

      # Home configs work on all *nix systems
      home-manager = {
        enable = true;
        justfile = mkJustRecipe {
          drv = pkgs.home-manager;
          os = "unix";
          extraArgs = builderArgs ++ ["-b bak"];
          alias = "home";
        };
      };

      # nix works on all *nix systems
      nix = {
        enable = true;
        justfile = mkJustRecipe {
          drv = pkgs.nixFlakes;
          os = "unix";
          extraArgs = commonArgs;
        };
      };

      flake = {
        enable = true;
        justfile = ''
          flake *ARGS: (nix "flake" ARGS)
        '';
      };

      build = {
        enable = true;
        justfile = ''
          build *ARGS: (nix "build" replace_regex(ARGS, \
                                                    "#([[:ascii:]]+)", \
                                                    "#$1 --out-link $1"))
        '';
      };

      develop = {
        enable = true;
        justfile = ''
          develop *ARGS: (nix "develop" ARGS)
        '';
      };

      run = {
        enable = true;
        justfile = ''
          run *ARGS: (add) (nix "run" ARGS)
        '';
      };

      show = {
        enable = true;
        justfile = ''
          show *ARGS: (flake "show" ARGS)
        '';
      };

      check = {
        enable = true;
        justfile = ''
          check *ARGS: (fmt) (add) (run)
        '';
      };

      git = {
        enable = true;
        justfile = ''
          [no-exit-message]
          git *ARGS:
              ${lib.getExe pkgs.git} {{ ARGS }}
        '';
      };

      add = {
        enable = true;
        justfile = ''
          add +ARGS="-u": (git "add" "--chmod=+x" ARGS)
        '';
      };

      commit = {
        enable = true;
        justfile = ''
          commit +ARGS="--dry-run": (add "-u")
            ${lib.getExe pkgs.git} commit {{ ARGS }}
        '';
      };

      amend = {
        enable = true;
        justfile = ''
          amend +ARGS="--dry-run": (add "-u") (commit "--amend" ARGS)
        '';
      };

      rekey = {
        enable = true;
        justfile = ''
          rekey *ARGS:
            env --chdir "$FLAKE_ROOT/secrets" \
              ${lib.getExe' inputs'.agenix.packages.default "agenix"} -r {{ ARGS }}
        '';
      };

      burn = {
        enable = true;
        justfile = ''
          burn DISK +ARGS: (build ARGS)
            ${lib.getExe' pkgs.findutils "find"} {{ replace_regex(ARGS, "#([[:ascii:]]+)", "$1") }} \
                  -type f -name "*.iso" -print0 | ${lib.getExe' pkgs.coreutils "xargs"} -0 -I {} \
                    ${lib.getExe' pkgs.coreutils "dd"} if={} of={{ DISK }} status=progress conv=fsync bs=64M
        '';
      };
    };
  };
}
