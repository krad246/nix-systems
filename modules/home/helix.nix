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

        lsp = {
          # diplay-progress-messages = true;
          display-inlay-hints = true;
        };

        cursor-shape = {
          normal = "block";
          insert = "bar";
        };

        auto-pairs = false;

        whitespace = {
          render = "all";
        };

        indent-guides = {
          render = true;
        };

        soft-wrap = {
          enable = true;
        };

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
          "C-R" = ":rl";

          "C-w" = ":bc";
          "C-q" = ":q";

          "C-x" = "no_op";
          "C-a" = [
            "select_mode"
            "select_all"
          ];

          "C-p" = "file_picker";

          "C-]" = "goto_next_buffer";
          "C-[" = "goto_previous_buffer";

          "C-c" = "no_op";
          "C-/" = "toggle_block_comments";

          # "A-e" = "no_op";
          # "A-b" = "no_op";

          # # uppercase / lowercase converters
          # "`" = "no_op";
          # "A-`" = "no_op";
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

            # selection splitting & merging
            S = "no_op";
            "A-s" = "no_op";
            "A-minus" = "no_op";
            "A-_" = "no_op";

            # multi-cursor direction
            # "A-;" = "no_op";
            # "A-:" = "no_op";
          };
      in {
        normal =
          noedit
          // {
            # space = {
            #   c = "no_op";
            #   C = "no_op";
            #   "A-c" = "no_op";
            #   p = "no_op";
            #   P = "no_op";
            #   G = "no_op";
            # };

            # "C-P" = "command_palette";
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
