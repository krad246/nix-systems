{
  flake.modules.homeManager.helix = {
    programs.helix.settings = {
      theme = "gruvbox_dark_soft";

      editor = {
        default-yank-register = "+";

        cursorline = true;
        cursorcolumn = true;

        continue-comments = false;

        bufferline = "multiple";

        color-modes = true;

        # trim-final-newlines = true;
        # trim-trailing-whitespace = true;

        popup-border = "all";

        end-of-line-diagnostics = "hint";

        # clipboard-provider = {
        # };

        # statusline = {
        # };

        lsp = {
          # display-progress-messages = true;
          display-inlay-hints = true;
        };

        file-picker = {
          hidden = false;
        };

        cursor-shape = {
          normal = "block";
          insert = "bar";
        };

        auto-pairs = false;

        # auto-save = {
        # };

        # search = {
        # };

        whitespace = {
          render = "all";
        };

        indent-guides = {
          render = true;
        };

        # gutters = {
        # };

        soft-wrap = {
          enable = true;
        };

        smart-tab = {
          enable = false;
        };

        inline-diagnostics = {
          cursor-line = "warning";
          # other-lines = "warning";
        };
      };
    };
  };
}
