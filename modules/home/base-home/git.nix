{
  config,
  lib,
  pkgs,
  ...
}: let
  # inherit (pkgs) lib;
  inherit (lib) meta modules;
in {
  programs = {
    git = {
      enable = true;
      lfs.enable = true;

      aliases = {
        whoami = "config user.name";
        tree = "log --pretty=oneline --graph --decorate --all --reflog";
      };

      extraConfig = {
        apply.whitespace = "fix";
        branch.sort = "-committerdate";

        core = {
          eol = "lf";
          autocrlf = "input";
          fileMode = false;
          untrackedCache = true;
          attributesFile = "${config.home.homeDirectory}/.gitattributes";
          excludesFile = "${config.home.homeDirectory}/.gitignore";
          whitespace = "space-before-tab,-indent-with-non-tab,trailing-space";
        };

        diff = {
          colorMoved = "default";
          renames = "copies";
          bin.textconv = "hexdump -v -C";
        };

        help.autocorrect = 1;

        merge = {
          conflictStyle = "zdiff3";
          log = true;
        };

        pull.rebase = true;
        push = {
          default = "simple";
          followtags = true;
          autoSetupRemote = true;
        };

        rebase = {
          autoStash = true;
          autoSquash = true;
        };

        safe.directory = "*";
      };

      userName = "Keerthi Radhakrishnan";

      # Prettier pager, adds syntax highlighting and line numbers
      delta = {
        enable = true;
        options = {
          navigate = true;
          line-numbers = true;
          hyperlinks = true;
          side-by-side = true;
        };
      };
    };

    lazygit = {
      enable = true;
      package = pkgs.unstable.lazygit;
      settings = {
        gui = {
          showNumstatInFilesView = true;
          nerdFontsVersion = "3";
          showBranchCommitHash = true;
          showDivergenceFromBaseBranch = "arrowAndNumber";
          # screenMode = "half";
          statusPanelView = "allBranchesLog";
        };
        git = {
          pagers = [
            {
              pager = let
                inherit (config.programs.git.delta) enable package;
                bin =
                  meta.getExe package;
              in
                modules.mkIf enable (pkgs.lib.krad246.cli.toGNUCommandLineShell bin {
                  no-gitconfig = true;
                  paging = "never";
                });
            }
          ];
          merging = {manualCommit = true;};
          autoForwardBranches = "allBranches";
          parseEmoji = true;
        };
        update = {
          method = "never";
        };
        keybinding = {
          universal = {
            # pushFiles = "p";
            # pullFiles = "P";
            increaseRenameSimilarityThreshold = "<disabled>";
            decreaseRenameSimilarityThreshold = "<disabled>";
          };
          status = {
            # checkForUpdate = "<disabled>";
            recentRepos = "<c-r>";
            allBranchesLogGraph = "<disabled>";
          };
          files = {
            toggleTreeView = "<disabled>";
          };
        };
      };
    };
    git-credential-oauth.enable = true;

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
  };
}
