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

        cursorline = true;
        cursorcolumn = true;

        bufferline = "multiple";
        color-modes = true;

        popup-border = "all";

        cursor-shape = {
          normal = "block";
          insert = "bar";
        };

        whitespace = {
          render = "all";
        };
      };

      keys = {
        insert = {
          "C-s" = ":w";
          "C-/" = "toggle_block_comments";
        };

        select = {
          "C-s" = ":w";
          "C-/" = "toggle_block_comments";
        };

        normal = {
          # s = "no_op"; # disable select_regex
          "C-s" = ":w";
          "C-w" = ":bc";
          "C-r" = ":rl";
          "C-q" = ":q";

          # "A-F" = ":fmt";

          # swap paste operations
          # default behavior is to now paste at the cursor position

          p = "paste_before";
          P = "paste_after";

          "0" = "goto_line_start";
          "^" = "goto_first_nonwhitespace";
          "$" = "goto_line_end";

          G = "goto_file_end";
          V = [
            "select_mode"
            "extend_to_line_bounds"
          ];

          "C-a" = [
            "select_mode"
            "select_all"
          ];

          "C-p" = "file_picker";

          "C-]" = "goto_next_buffer";
          "C-[" = "goto_previous_buffer";

          "C-c" = "no_op";
          "C-/" = "toggle_block_comments";

          t = "no_op";
          f = "no_op";

          T = "no_op";
          F = "no_op";

          "C-f" = "no_op";
          "C-b" = "no_op";

          q = "no_op";
          Q = "no_op";

          "C-x" = "no_op";

          space = {
            c = "no_op";
            C = "no_op";
            "A-c" = "no_op";
            p = "no_op";
            P = "no_op";
            G = "no_op";
          };

          "C-P" = "command_palette";
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
