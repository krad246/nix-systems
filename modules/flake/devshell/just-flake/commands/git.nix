_: {
  perSystem = _: {
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
    };
  };
}
