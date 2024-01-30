{config, ...}: {
  programs = {
    git = {
      enable = true;
      lfs.enable = true;

      aliases = {
        whoami = "config user.name";
        tree = "log --pretty=oneline --graph --decorate --all";
      };

      extraConfig = {
        aply.whitespace = "fix";
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
          renames = "copies";
          bin.textconv = "hexdump -v -C";
        };

        help.autocorrect = 1;

        merge.log = true;

        pull.rebase = true;
        push = {
          default = "simple";
          followtags = true;
        };

        rebase = {
          autoStash = true;
          autoSquash = true;
        };

        safe.directory = "*";
      };

      userEmail = "krad246@gmail.com";
      userName = "Keerthi Radhakrishnan";

      # Prettier pager, adds syntax highlighting and line numbers
      delta = {
        enable = false;
        options = {
          navigate = true;
          line-numbers = true;
          conflictstyle = "diff3";
        };
      };
    };

    lazygit.enable = true;
    git-credential-oauth.enable = true;

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
  };

  home = {
    file."./.config/gh/" = {
      source = ./.;
      recursive = true;
    };

    # Treesitter is configured as a locally developed module in lazy.nvim
    # we hardcode a symlink here so that we can refer to it in our lazy config
    file."./.config/git/" = {
      recursive = true;
      source = ./.;
    };
  };
}
