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
          scrollPastBottom = false;
          expandFocusedSidePanel = true;
          showNumstatInFilesView = true;
          nerdFontsVersion = "3";
          showBranchCommitHash = true;
          showDivergenceFromBaseBranch = "arrowAndNumber";
          # screenMode = "half";
          statusPanelView = "allBranchesLog";
          switchTabsWithPanelJumpKeys = false;
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
          ignoreWhitespaceInDiffView = true;
          parseEmoji = true;
        };
        update = {
          method = "never";
        };
        keybinding = {
          universal = {
            quit-alt1 = "<c-q>";

            # prevItem = "<disabled>";
            # nextItem = "<disabled>";

            prevPage = "<pgup>";
            nextPage = "<pgdown>";

            scrollLeft = "h";
            scrollRight = "l";

            gotoTop = "<home>";
            gotoBottom = "<end>";
            gotoTop-alt = "<disabled>";
            gotoBottom-alt = "<disabled>";

            prevBlock = "<backtab>";
            nextBlock = "<tab>";
            prevBlock-alt = "<disabled>";
            nextBlock-alt = "<disabled>";
            nextBlock-alt2 = "<disabled>";
            prevBlock-alt2 = "<disabled>";

            # optionMenu = "<disabled>";

            openFile = "<disabled>";

            scrollUpMain = "<disabled>";
            scrollDownMain = "<disabled>";
            scrollUpMain-alt1 = "<disabled>";
            scrollDownMain-alt1 = "<disabled>";
            scrollUpMain-alt2 = "<disabled>";
            scrollDownMain-alt2 = "<disabled>";

            # pushFiles = "p";
            # pullFiles = "P";

            refresh = "<c-r>";

            createPatchOptionsMenu = "<disabled>";

            # nextTab = "<tab>";
            # prevTab = "<backtab>";

            filteringMenu = "<c-f>";
            diffingMenu = "<c-d>";
            diffingMenu-alt = "<disabled>";

            copyToClipboard = "<c-c>";

            # openRecentRepos = "<c-p>";
            openRecentRepos = "<disabled>";

            toggleWhitespaceInDiffView = "<disabled>";

            # increaseRenameSimilarityThreshold = "<disabled>";
            # decreaseRenameSimilarityThreshold = "<disabled>";
          };
          status = {
            # checkForUpdate = "<disabled>";
            allBranchesLogGraph = "<disabled>";
          };
          files = {
            commitChangesWithoutHook = "C";
            commitChangesWithEditor = "<disabled>";
            findBaseCommitForFixup = "b";
            # confirmDiscard = "x";
            refreshFiles = "<disabled>";
            # stashAllChanges = "<disabled>";
            viewResetOptions = "r";
            fetch = "<disabled>";
            toggleTreeView = "<disabled>";
            openStatusFilter = "<disabled>";
            # openStatusFilter = "<c-s>";
          };
          branches = {
            createPullRequest = "<disabled>";
            # fetchRemote = "<disabled>";
          };
          commits = {
            # viewResetOptions = "R";
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
