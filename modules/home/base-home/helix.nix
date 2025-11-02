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

        smart-tab = {
          enable = false;
        };

        inline-diagnostics = {
          cursor-line = "warning";
          # other-lines = "warning";
        };
      };

      keys = let
        # keybinds valid in all modes
        base = {
          # basic editor control
          "C-s" = ":w";
          "C-r" = ":rla";
          "C-w" = ":bc";
          "C-q" = ":q";
          "C-z" = "suspend";

          # buffer view control
          "C-]" = "goto_next_buffer";
          "C-[" = "goto_previous_buffer";

          # tiling management
          "C-v" = rec {
            h = "jump_view_left";
            "C-h" = h;
            "C-[" = h;

            j = "jump_view_down";
            "C-j" = j;
            k = "jump_view_up";
            "C-k" = k;

            l = "jump_view_right";
            "C-l" = l;
            "C-]" = l;

            H = "swap_view_left";
            "C-H" = H;

            J = "swap_view_down";
            "C-J" = J;

            K = "swap_view_up";
            "C-K" = K;

            L = "swap_view_right";
            "C-L" = L;

            t = "transpose_view";
            "C-t" = t;

            r = "vsplit";
            "C-r" = r;
            b = "hsplit";
            "C-b" = b;

            o = "wonly";
            "C-o" = o;
            q = "wclose";
            "C-q" = q;
          };

          # jumplist management
          "C-i" = "no_op";
          "C-o" = "no_op";
          "C-J" = "jumplist_picker";
          "C-j" = {
            "C-j" = "save_selection";

            "C-]" = "jump_forward";
            "C-[" = "jump_backward";
          };

          # some basic pickers
          "C-p" = "file_picker";
          "C-P" = "command_palette";
          "C-?" = "global_search";
          "C-F" = "global_search";

          # shorthand text operations I like
          "C-/" = "toggle_comments";

          # TODO: figure out what to do with these
          "C-c" = "no_op";
          "C-x" = "no_op";
        };

        noedit =
          base
          // {
            # 'bracket' menus
            # "[" = "no_op";
            # "]" = "no_op";

            # pickers
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

            # history management
            "A-U" = "no_op";
            "A-u" = {
              "A-u" = "commit_undo_checkpoint";

              "A-]" = "later";
              "A-[" = "earlier";
            };

            # shell piping
            "|" = "shell_pipe";
            "A-|" = "no_op";

            "!" = "shell_append_output";
            "A-!" = "shell_insert_output";

            # macros
            q = "no_op";
            Q = "no_op";

            # multi-cursor creation + collapse
            C = "copy_selection_on_next_line";
            "A-C" = "copy_selection_on_prev_line";
            "," = "keep_primary_selection";
            "A-," = "remove_primary_selection";

            # selection splitting & merging
            S = "split_selection";
            "A-s" = "no_op";
            "A-S" = "merge_selections";
            "A-minus" = "no_op";
            "A-_" = "no_op";
            ";" = "collapse_selection";
            "(" = "rotate_selections_backward";
            ")" = "rotate_selections_forward";

            # multi-cursor direction
            "A-;" = "flip_selections";
            "A-:" = "no_op";

            # structural selection editing
            "=" = "no_op";
            "&" = "no_op";
            "J" = "no_op";
            "A-J" = "no_op";
            "K" = "no_op";
            "A-K" = "no_op";

            "A-(" = "no_op";
            "A-)" = "no_op";

            # uppercase / lowercase converters
            "~" = "switch_case";
            "`" = "no_op";
            "A-`" = "no_op";

            # some small text operations I like
            "^" = "goto_first_nonwhitespace";
            V = [
              "select_mode"
              "extend_to_line_bounds"
            ];
            "C-a" = [
              "select_mode"
              "select_all"
            ];

            # text object selectors

            "A-e" = "expand_selection";
            "A-b" = "shrink_selection";

            "A-I" = "no_op";
            "S-A-down" = "no_op";

            "A-a" = "no_op";

            "A-left" = "no_op";
            "A-p" = "no_op";
            "A-N" = "select_prev_sibling";

            "A-n" = "select_next_sibling";
            # "A-n" = "no_op";
            "A-right" = "no_op";

            "A-i" = "no_op";
            "A-down" = "no_op";
            "A-o" = "no_op";
            "A-up" = "no_op";
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
            # character delete forward / backward
            "C-h" = "no_op";
            "C-d" = "no_op";

            # delete word forward / backward
            "A-backspace" = "no_op";
            "C-backspace" = "delete_word_backward";
            "A-d" = "no_op";
            "A-del" = "no_op";
            "C-del" = "delete_word_forward";

            # jumping around text
            "C-a" = "goto_first_nonwhitespace";
            "C-e" = "goto_line_end";
            "C-left" = "evil_prev_word_start";
            "C-right" = "evil_next_word_start";
          };
      };
    };

    ignores = [];

    languages = {
      language = [
        {
          name = "bash";
          language-servers = ["bash-language-server"];
        }
        {
          name = "c";
          language-servers = ["clangd"];
        }
        {
          name = "cmake";
          language-servers = ["neocmakelsp"];
        }
        {
          name = "cpp";
          language-servers = ["clangd"];
        }
        {
          name = "docker-compose";
          language-servers = ["yaml-language-server"];
        }
        {
          name = "dockerfile";
          language-servers = ["docker-langserver"];
        }
        {
          name = "just";
          language-servers = ["just-lsp"];
        }
        {
          name = "markdown";
          language-servers = ["marksman"];
        }
        {
          name = "nix";
          language-servers = ["nixd"];
          # formatter = {
          #   command = lib.meta.getExe pkgs.alejandra;
          # };
        }
        # {
        #   name = "python";
        #   language-servers = [];
        # }
        {
          name = "rust";
          language-servers = ["rust-analyzer"];
        }
        # {
        #   name = "systemd";
        #   language-servers = ["systemd-lsp"];
        # }
        # {
        #   name = "toml";
        #   language-servers = ["tombi"];
        # }
        {
          name = "yaml";
          language-servers = ["yaml-language-server"];
        }
      ];

      language-server = {
        bash-language-server.command = lib.meta.getExe pkgs.bash-language-server;
        clangd.command = lib.meta.getExe' pkgs.clang-tools "clangd";
        docker-langserver.command = lib.meta.getExe pkgs.docker-language-server;
        just-lsp.command = lib.meta.getExe pkgs.just-lsp;
        marksman.command = lib.meta.getExe pkgs.marksman;
        neocmakelsp.command = lib.meta.getExe pkgs.neocmakelsp;
        nixd.command = lib.meta.getExe pkgs.nixd;
        rust-analyzer.command = lib.meta.getExe pkgs.rust-analyzer;
        systemd-lsp.command = lib.meta.getExe (pkgs.systemd-language-server.overrideAttrs (_old: {
          doCheck = false;
        }));
        # tombi.command = lib.meta.getExe pkgs.tombi;
        # vscode-json-language-server.command = lib.meta.getExe pkgs.vscode-json-language-server;
        yaml-language-server.command = lib.meta.getExe pkgs.yaml-language-server;
      };
    };
  };
}
