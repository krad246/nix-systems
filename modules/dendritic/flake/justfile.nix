{
  inputs,
  lib,
  ...
}: {
  imports = lib.lists.optionals (inputs ? just-flake) [
    inputs.just-flake.flakeModule
  ];

  flake-file = {
    inputs = {
      just-flake.url = "github:juspay/just-flake";
    };
  };

  perSystem = {config, ...}: {
    just-flake.features = {
      add = {
        enable = true;
        justfile = ''
          # Equivalent to `git add -u` by default, unless other args are passed.
          [group('git')]
          add +ARGS="-u":
            git add --chmod=+x {{ ARGS }}
        '';
      };

      commit = {
        enable = true;

        justfile = ''
          # Equivalent to `git add -u` followed by `git commit --dry-run`, unless other args are passed.
          [group('git')]
          commit +ARGS="--dry-run": (add "-u")
            git commit {{ ARGS }}
        '';
      };

      amend = {
        enable = true;

        justfile = ''
          # Equivalent to `git add -u` followed by `git commit -a --amend`, with other args passed to its invocation.
          [group('git')]
          amend +ARGS="--dry-run": (add "-u")
            git commit -a --amend {{ ARGS }}
        '';
      };

      build = {
        enable = true;

        justfile = ''
          # Wraps `nom build`.
          [group('nix')]
          build *ARGS: lock
            nom build {{ ARGS }}
        '';
      };

      develop = {
        enable = true;

        justfile = ''
          # Wraps `nom develop`.
          [group('nix')]
          develop *ARGS: lock
            nom develop {{ ARGS }}
        '';
      };

      shell = {
        enable = true;

        justfile = ''
          # Wraps `nom shell`.
          [group('nix')]
          shell *ARGS:
            nom shell {{ ARGS }}
        '';
      };

      run = {
        enable = true;

        justfile = ''
          # Wraps `nix run`.
          [group('nix')]
          run *ARGS: lock
            nix run {{ ARGS }}
        '';
      };

      search = {
        enable = true;

        justfile = ''
          # Wraps `nix search`.
          [group('nix')]
          search *ARGS:
            nix search {{ ARGS }}
        '';
      };

      show = {
        enable = true;

        justfile = ''
          # Wraps `nix flake show`.
          [group('nix')]
          show *ARGS:
            nix flake show {{ ARGS }}
        '';
      };

      check = {
        enable = true;

        justfile = ''
          # Wraps `nix flake check`.
          [group('nix')]
          check *ARGS:
            nix flake check {{ ARGS }}
        '';
      };

      repl = {
        enable = true;

        justfile = ''
          # Wraps `nix repl .`;
          [group('nix')]
          repl *ARGS: lock
            nix repl --file "$(${lib.meta.getExe config.flake-root.package})" {{ ARGS }}
        '';
      };

      lock = {
        enable = true;

        justfile = ''
          # Wraps `git add -A && nix flake lock`.
          [group('nix')]
          lock *ARGS: (add "-A")
            nix flake lock {{ ARGS }}
        '';
      };

      update = {
        enable = true;

        justfile = ''
          # Wraps `git add -A && nix flake update`.
          [group('nix')]
          update *ARGS: (add "-A")
            nix flake update {{ ARGS }}
        '';
      };

      treefmt.enable = true;
    };
  };
}
