{
  lib,
  pkgs,
  ...
}: {
  programs.helix = {
    enable = true;
    # package = pkgs.evil-helix;
    defaultEditor = true;

    extraPackages = [
    ];

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

    settings = {
      theme = "gruvbox_dark_soft";
      editor = {
        # evil = true;
        # continue-comments = false;
        # default-yank-register = "+";
        # soft-wrap.enable = true;
      };

      keys = {
        normal = {
          C-r = ":config-reload";

          o = ["open_below" "normal_mode"];
          O = ["open_above" "normal_mode"];

          "0" = "goto_line_start";
          "^" = "goto_first_nonwhitespace";
          "$" = "goto_line_end";

          G = "goto_file_end";

          V = ["select_mode" "extend_to_line_bounds"];

          x = "delete_selection";
          # X = "no_op";
          # "A-x" = "no_op";

          w = ["move_next_word_start" "move_char_right" "collapse_selection"];
          W = ["move_next_long_word_start" "move_char_right" "collapse_selection"];
          e = ["move_next_word_end" "collapse_selection"];
          E = ["move_next_long_word_end" "collapse_selection"];
          b = ["move_prev_word_start" "collapse_selection"];
          B = ["move_prev_long_word_start" "collapse_selection"];

          i = ["insert_mode" "collapse_selection"];
          a = ["append_mode" "collapse_selection"];

          u = ["undo" "collapse_selection"];

          esc = ["collapse_selection" "keep_primary_selection"];
        };

        select = {
          "0" = "goto_first_nonwhitespace";
          "$" = "goto_line_end";
        };
      };
    };
  };
}
