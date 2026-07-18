{lib, ...}: {
  flake.modules.homeManager.git = inner @ {config, ...}: {
    programs.git = {
      lfs.enable = true;
      settings = {
        user.name = lib.modules.mkDefault config.identity.person.name;
        user.email = lib.modules.mkDefault config.identity.person.email;

        apply.whitespace = "fix";
        branch.sort = "-committerdate";

        core = {
          eol = "lf";
          autocrlf = "input";
          fileMode = false;
          untrackedCache = true;
          attributesFile = "${inner.config.home.homeDirectory}/.gitattributes";
          excludesFile = "${inner.config.home.homeDirectory}/.gitignore";
          whitespace = "space-before-tab,-indent-with-non-tab,trailing-space";
        };

        diff = {
          colorMoved = "default";
          renames = "copies";
          bin.textconv = "hexdump -v -C";
        };

        help.autocorrect = 1;

        merge = {
          conflictStyle = "zdiff3";
          log = true;
        };

        pull.rebase = true;
        push = {
          default = "simple";
          followtags = true;
          autoSetupRemote = true;
        };

        rebase = {
          autoStash = true;
          autoSquash = true;
        };

        safe.directory = "*";
      };
    };
  };
}
