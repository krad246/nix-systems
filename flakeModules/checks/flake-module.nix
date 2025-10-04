{
  perSystem = {config, ...}: {
    treefmt = {
      inherit (config.flake-root) projectRootFile;
      flakeCheck = false;
      programs = {
        alejandra.enable = true;
        deadnix = {
          enable = true;
          no-underscore = true;
        };
        dos2unix.enable = false;
        just.enable = true;
        keep-sorted.enable = true;
        shellcheck.enable = true;
        shfmt.enable = true;
        statix.enable = true;
        typos.enable = false;
      };
    };

    pre-commit = {
      settings = {
        excludes = ["\\.(age)$"];
        hooks = {
          alejandra.enable = true;
          check-added-large-files.enable = true;
          check-case-conflicts.enable = true;
          check-executables-have-shebangs.enable = true;
          check-merge-conflicts.enable = true;
          check-shebang-scripts-are-executable.enable = true;
          check-symlinks.enable = true;
          checkmake.enable = false;
          cspell = {
            enable = false;
          };
          deadnix.enable = true;
          detect-private-keys.enable = true;
          end-of-file-fixer.enable = false;
          flake-checker.enable = false;
          markdownlint.enable = false;
          mdl.enable = false;
          mixed-line-endings.enable = true;
          mkdocs-linkcheck.enable = false;
          nil.enable = true;
          ripsecrets.enable = true;
          shellcheck.enable = true;
          shfmt.enable = true;
          statix.enable = true;
          treefmt = {
            enable = false;
            settings = {fail-on-change = true;};
          };
          trim-trailing-whitespace.enable = true;
          trufflehog.enable = false;
        };
      };

      check.enable = true;
    };
  };
}
