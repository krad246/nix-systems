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
        normal = {
          s = "no_op"; # disable select_regex
          "C-s" = ":w"; # Maps Ctrl-s to the typable command :w which is an alias for :write (save file)

          # swap paste operations
          # default behavior is to now paste at the cursor position

          p = "paste_before";
          P = "paste_after";

          "0" = "goto_line_start";
          "^" = "goto_first_nonwhitespace";
          "$" = "goto_line_end";

          G = "goto_file_end";
          V = [
            # "select_mode"
            "extend_to_line_bounds"
          ];

          "C-a" = [
            # "select_mode"
            "select_all"
          ];

          "C-p" = "file_picker";
          "C-E" = "file_picker";

          "C-]" = "goto_next_buffer";
          "C-[" = "goto_previous_buffer";

          # TODO:
          # add_newline_below (<Space>j)
          # add_newline_above (<Space>k)

          # replace_with_yanked (R)
        };
      };
    };

    ignores = [];

    languages = {
      language = [
        {
          name = "c";
          language-servers = ["clangd"];
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
        }
      ];

      language-server = {
        marksman.command = lib.meta.getExe pkgs.marksman;
        nixd.command = lib.meta.getExe pkgs.nixd;
      };
    };
  };
}
