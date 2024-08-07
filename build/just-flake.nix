{
  perSystem = {
    lib,
    pkgs,
    inputs',
    ...
  }: let
    # Compose a simple just target from the name of the incoming derivation
    mkJustRecipe = args @ {
      drv,
      os,
      extraArgs,
      ...
    }: let
      # Conditionally include an alias line if an alias is passd
      maybeString = pred: val: lib.strings.optionalString pred val;
      mkAlias = alias: pname: "alias ${alias} := ${pname}";

      # Extract the package symbolic name without the version
      name = lib.strings.getName drv;
      version = lib.strings.getVersion drv;
      pname = lib.strings.removePrefix "-${version}" name;
    in ''
      # `${pname}` related subcommands. Syntax: just ${pname} <subcommand>
      [${os}]
      ${pname} VERB *ARGS:
        @${lib.meta.getExe drv} {{ VERB }} ${lib.strings.concatStringsSep " " extraArgs} {{ ARGS }}

      ${maybeString (args ? alias) (mkAlias args.alias pname)}
    '';
  in {
    just-flake.features = let
      # Extra args to tack onto the invocation wrappers below...
      flakeRoot = "\"$FLAKE_ROOT\"";
      commonArgs = ["--option experimental-features 'nix-command flakes'" "--option inputs-from ${flakeRoot}"];
      flakeArgs = ["--flake ${flakeRoot}"];
      builderArgs = commonArgs ++ flakeArgs;
    in {
      treefmt.enable = true;

      # Add a wrapper around nixos-rebuild to devShell instances if we're on Linux
      nixos-rebuild = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
        enable = true;
        justfile = mkJustRecipe {
          drv = pkgs.nixos-rebuild;
          os = "linux";
          extraArgs = builderArgs ++ ["--use-remote-sudo"];
          alias = "os";
        };
      };

      # Add a wrapper around nixos-rebuild to devShell instances if we're on Darwin
      darwin-rebuild = lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
        enable = true;
        justfile = mkJustRecipe {
          drv = inputs'.darwin.packages.darwin-rebuild;
          os = "macos";
          extraArgs = builderArgs;
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

      commit = {
        enable = true;
        justfile = let
          gitBin = lib.getExe pkgs.git;
        in ''
          commit *ARGS:
            @${gitBin} add -u && ${gitBin} commit {{ quote(ARGS) }}
        '';
      };

      docker-exec = {
        enable = true;
        justfile = ''
          docker-exec SYSTEM *ARGS:
            @${lib.getExe pkgs.just} nix run .#packages.{{SYSTEM}}.docker-builder-exec -- {{ ARGS }}
        '';
      };
    };
  };
}
