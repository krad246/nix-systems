{
  flake.modules.homeManager.lazygit = {
    programs.lazygit.settings.keybinding = {
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

        # optionMenu = "<c-P>";

        # openFile = "<disabled>";

        scrollUpMain = "<disabled>";
        scrollDownMain = "<disabled>";
        scrollUpMain-alt1 = "<disabled>";
        scrollDownMain-alt1 = "<disabled>";
        scrollUpMain-alt2 = "<disabled>";
        scrollDownMain-alt2 = "<disabled>";

        # pushFiles = "p";
        # pullFiles = "P";

        # refresh = "<c-r>";

        createPatchOptionsMenu = "<c-p>";

        # nextTab = "<tab>";
        # prevTab = "<backtab>";

        filteringMenu = "<c-f>";
        diffingMenu = "<c-d>";
        diffingMenu-alt = "<disabled>";

        copyToClipboard = "<c-c>";

        openRecentRepos = "<disabled>";

        toggleWhitespaceInDiffView = "<disabled>";

        # increaseRenameSimilarityThreshold = "<disabled>";
        # decreaseRenameSimilarityThreshold = "<disabled>";
        openDiffTool = "<disabled>";
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
        viewResetOptions = "D";
        # fetch = "<disabled>";
        toggleTreeView = "<disabled>";
        openStatusFilter = "<c-s>";
        collapseAll = "<disabled>";
        expandAll = "<disabled>";
      };

      branches = {
        createPullRequest = "<disabled>";
        viewPullRequestOptions = "o";
        # copyPullRequestURL =
        forceCheckoutBranch = "C";
        renameBranch = "B";
        # renameBranch =
        # fetchRemote = "<disabled>";
      };

      commits = {
        renameCommit = "r";
        renameCommitWithEditor = "<disabled>";
        # viewResetOptions = "R";
      };
    };
  };
}
