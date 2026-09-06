{
  flake.modules.homeManager.yazi = {
    programs.yazi.settings = rec {
      mgr = manager;
      manager = {
        ratio = [2 2 4];
        sort_by = "natural";
        sort_sensitive = true;
        sort_dir_first = false;
        sort_translit = true;
        show_hidden = true;
        show_symlink = true;
        mouse_events = [
          "click"
          "scroll"
          "touch"
          "move"
          "drag"
        ];
        # title_format = "{cwd}";
      };

      preview = {
        wrap = "yes";
        tab_size = 4;
      };

      opener = {
      };

      plugin = {
      };

      input = {
        cursor_blink = true;
      };

      which = {
      };
    };
  };
}
