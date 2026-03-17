{
  flake.modules.homeManager.lazygit = {pkgs, ...}: {
    programs.lazygit = {
      package = pkgs.unstable.lazygit;
      settings = {
        gui = {
          scrollPastBottom = false;
          expandFocusedSidePanel = true;
          showNumstatInFilesView = true;
          nerdFontsVersion = "3";
          showBranchCommitHash = true;
          showDivergenceFromBaseBranch = "arrowAndNumber";
          commandLogSize = 16;
          # screenMode = "half";
          statusPanelView = "allBranchesLog";
          switchTabsWithPanelJumpKeys = false;
        };

        git = {
          merging.manualCommit = true;
          autoForwardBranches = "allBranches";
          ignoreWhitespaceInDiffView = true;
          parseEmoji = true;
        };

        update.method = "never";
      };
    };
  };
}
