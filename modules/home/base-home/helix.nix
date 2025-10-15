{
  lib,
  pkgs,
  ...
}: {
  programs.helix = {
    enable = true;
    defaultEditor = true;

    package = pkgs.evil-helix;
    extraPackages = [];

    settings = {
      theme = "gruvbox_dark_soft";

      editor = {
        evil = true;

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
          # diplay-progress-messages = true;
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

        # smart-tab = {
        # };

        inline-diagnostics = {
          cursor-line = "warning";
          # other-lines = "warning";
        };
      };

      keys = let
        base = {
          "C-s" = ":w";
          "C-S" = ":wa";

          "C-r" = ":rl";

          "C-w" = ":bc";
          "C-q" = ":q";

          "C-x" = "no_op";
          "C-a" = [
            "select_mode"
            "select_all"
          ];

          "C-p" = "file_picker";
          "C-P" = "command_palette";

          "C-]" = "goto_next_buffer";
          "C-[" = "goto_previous_buffer";

          "C-c" = "no_op";
          "C-/" = "toggle_comments";

          "C-F" = "global_search";

          "A-e" = "no_op";
          "A-b" = "no_op";

          # uppercase / lowercase converters
          # "`" = "no_op";
          # "A-`" = "no_op";

          C-i = "no_op";
          C-o = "no_op";
          "C-v" = {
            "h" = "jump_view_left";
            "C-h" = "jump_view_left";
            "j" = "jump_view_down";
            "C-j" = "jump_view_down";
            "k" = "jump_view_up";
            "C-k" = "jump_view_up";
            "l" = "jump_view_right";
            "C-l" = "jump_view_right";

            "H" = "swap_view_left";
            "C-H" = "swap_view_left";
            "J" = "swap_view_down";
            "C-J" = "swap_view_down";
            "K" = "swap_view_up";
            "C-K" = "swap_view_up";
            "L" = "swap_view_right";
            "C-L" = "swap_view_right";

            "t" = "transpose_view";
            "C-t" = "transpose_view";

            "r" = "vsplit";
            "C-r" = "vsplit";
            "b" = "hsplit";
            "C-b" = "hsplit";

            "o" = "wonly";
            "C-o" = "wonly";
            "q" = "wclose";
            "C-q" = "wclose";
          };
        };

        noedit =
          base
          // {
            t = "no_op";
            f = "no_op";

            T = "no_op";
            F = "no_op";

            q = "no_op";
            Q = "no_op";

            "^" = "goto_first_nonwhitespace";
            V = [
              "select_mode"
              "extend_to_line_bounds"
            ];

            # multi-cursor creation + collapse
            # C = "no_op";
            # "A-C" = "no_op";
            # ";" = "no_op";
            # "," = "no_op";

            # selection splitting & merging
            S = "no_op";
            "A-s" = "no_op";
            "A-minus" = "no_op";
            "A-_" = "no_op";

            # multi-cursor direction
            # "A-;" = "no_op";
            # "A-:" = "no_op";

            space = {
              # file picker
              f = "no_op";
              F = "no_op";

              # changed file picker
              g = "no_op";

              # buffer picker
              b = "no_op";

              # jumplist picker
              j = "no_op";

              # symbol picker
              # s = "no_op";
              # S = "no_op";

              # last picker
              "'" = "no_op";

              # code actions
              # a = "no_op";

              # diagnostics view
              # d = "no_op";
              # D = "no_op";

              # experimental debugging
              G = "no_op";

              # window management
              # w = "no_op";

              # yanking
              y = "no_op";
              Y = "no_op";

              # pasting
              p = "no_op";
              P = "no_op";

              # 'replace selections by clipboard contents'
              R = "no_op";

              # 'show documentation for item under cursor'
              k = "no_op";

              # symbol renaming
              r = "no_op";
              h = "no_op";

              # Comments
              c = "no_op";
              C = "no_op";
              "A-c" = "no_op";

              # view management
              w = "no_op";
            };
          };
      in {
        normal =
          noedit
          // {
          };

        select =
          noedit
          // {
          };

        insert =
          base
          // {
          };
      };
    };

    ignores = [];

    languages = {
      language = [
        {
          name = "c";
          language-servers = ["clangd"];
          auto-format = true;
        }
        {
          name = "just";
        }
        {
          name = "make";
        }
        {
          name = "markdown";
          language-servers = ["marksman"];
        }
        {
          name = "nix";
          formatter = {
            command = lib.meta.getExe pkgs.alejandra;
          };

          language-servers = ["nixd"];
          auto-format = true;
        }
      ];

      language-server = {
        marksman.command = lib.meta.getExe pkgs.marksman;
        nixd.command = lib.meta.getExe pkgs.nixd;
      };
    };
  };
}
