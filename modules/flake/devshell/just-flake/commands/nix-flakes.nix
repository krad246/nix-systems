{self, ...}: {
  perSystem = {
    just-flake.features = {
      build = {
        enable = true;

        justfile = ''
          # Wraps `nix build`.
          [group('nix')]
          build *ARGS: lock
            nix build {{ ARGS }}
        '';
      };

      develop = {
        enable = true;

        justfile = ''
          # Wraps `nix develop`.
          [group('nix')]
          develop *ARGS: lock
            nix develop {{ ARGS }}
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

      shell = {
        enable = true;

        justfile = ''
          # Wraps `nix shell`.
          [group('nix')]
          shell *ARGS:
            nix shell {{ ARGS }}
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
            nix repl --file "${self}" {{ ARGS }}
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
    };
  };
}
