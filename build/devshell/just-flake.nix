{
  inputs',
  self',
  pkgs,
  ...
}: let
  inherit (pkgs) lib;

  # Compose a simple just target from the name of the incoming derivation
  mkJustRecipe = {
    drv,
    pname ? lib.getName drv,
    os,
    extraArgs,
    argFmt ? "{{ VERB }} {{ ARGS }}",
    ...
  }: ''
    # `${pname}` related subcommands. Syntax: just ${pname} <subcommand>
    [${os}]
    [no-exit-message]
    @${pname} VERB *ARGS:
      #!${lib.meta.getExe pkgs.bash}
      ${lib.meta.getExe' drv pname} \
        ${lib.strings.concatStringsSep " \\\n    " extraArgs} \
        ${argFmt}
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
      extraArgs =
        builderArgs
        ++ [
          "--use-remote-sudo"
          "--flake $FLAKE_ROOT"
        ];
    };
  };

  # Add a wrapper around nixos-rebuild to devShell instances if we're on Darwin
  darwin-rebuild = lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {
    enable = true;
    justfile = mkJustRecipe {
      drv = inputs'.darwin.packages.darwin-rebuild;
      os = "macos";
      extraArgs =
        builderArgs
        ++ [
          "--flake $FLAKE_ROOT"
        ];
    };
  };

  # Home configs work on all *nix systems
  home-manager = {
    enable = true;
    justfile = mkJustRecipe {
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

  # nix works on all *nix systems
  nix = {
    enable = true;
    justfile = mkJustRecipe {
      drv = pkgs.nixFlakes;
      os = "unix";
      extraArgs = builderArgs;
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
      flakeref := "^(?<front>[[:ascii:]]+\\s)?(?<path>(?<flake>[[:ascii:]]+)#(?<ref>[[:ascii:]]+))\\s(?<back>[[:ascii:]]+)?$"
      outlink := "$flake/outputs/$ref"
      [private]
      _build *ARGS: (nix "build" ARGS)
      build *ARGS: (_build trim(replace_regex(ARGS, \
                                                flakeref, \
                                                "$front $path --out-link " + outlink + " $back")))
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
      check *ARGS: (fmt) (add) (flake "check" ARGS)
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
      commit +ARGS="--dry-run": (add "-u") (git "commit" ARGS)
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
            -L {{ replace_regex(ARGS, flakeref, outlink) }} -type f)"
    '';
  };

  container = {
    enable = true;
    justfile = ''
      [private]
      _make *ARGS:
        ${lib.getExe pkgs.gnumake} -f ${self'.packages.makefile} {{ ARGS }}

      container *VERBS: (_make prepend("container-", VERBS))
    '';
  };
}
