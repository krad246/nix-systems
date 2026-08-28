{lib, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    verifyDendriticContext = pkgs.writeShellApplication {
      name = "verify-dendritic-context";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.gawk
        pkgs.gnused
        pkgs.perl
      ];
      text = ''
        root="$(${lib.meta.getExe config.flake-root.package})"
        exec ${lib.meta.getExe pkgs.bash} \
          "$root/.agents/dendritic/context.sh" \
          --root "$root" \
          --bundle "$root/.agents/dendritic" \
          verify
      '';
    };
  in {
    packages.verify-dendritic-context = verifyDendriticContext;

    treefmt = {
      inherit (config.flake-root) projectRootFile;
      flakeCheck = false;
      settings.global.excludes = ["*.age"];
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
          verify-dendritic-context = {
            enable = true;
            description = "Verify the agent context bundle and generated proxy";
            entry = lib.meta.getExe verifyDendriticContext;
            files = "^(AGENTS\\.md|\\.agents/dendritic/)";
            pass_filenames = false;
            stages = ["pre-commit"];
          };

          sync-flake = {
            enable = true;
            description = "Keep the generated flake.nix synchronized with its module source";

            entry = lib.meta.getExe config.packages.write-flake;

            always_run = true;
            pass_filenames = false;

            stages = ["pre-merge-commit"];
          };
          check-flake = {
            enable = true;
            description = "Prevent pushing a flake that fails its checks";

            entry = lib.meta.getExe (pkgs.writeShellApplication {
              name = "check-flake";

              text = ''
                . ${config.checks.check-flake-file};
              '';

              extraShellCheckFlags = [
                "-x"
                config.checks.check-flake-file
                "-s"
                "bash"
              ];
            });

            always_run = true;
            pass_filenames = false;

            stages = ["pre-push"];
          };
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
