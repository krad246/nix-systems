outer: {
  flake.modules.homeManager.git = inner @ {
    osConfig,
    lib,
    ...
  }: {
    programs.git = {
      lfs.enable = true;
      settings = {
        user.name = osConfig.owner.name or outer.config.owner.name;
        user.email = lib.modules.mkDefault (osConfig.owner.email or outer.config.owner.email);

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
