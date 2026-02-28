{self, ...}: {
  flake.modules.homeManager.bottom = {
    lib,
    pkgs,
    ...
  }: {
    imports = [self.modules.homeManager.nixpkgs-unstable];

    programs.bottom = {
      package = pkgs.unstable.bottom;
      settings = {
        flags = {
          # current_usage = true;
          unnormalized_cpu = true;
          basic = lib.modules.mkDefault true;
          # expanded = true;
          hide_table_gap = true;
          battery = true;
          show_table_scroll_position = true;
          process_command = true;
          network_use_binary_prefix = true;
          network_use_bytes = true;
          hide_k_threads = false;
        };

        processes = {
          get_threads = true;
        };

        cpu = {
        };

        disk = {
        };

        temperature = {
        };

        network = {
        };

        # styles.theme = "gruvbox";
      };
    };
  };
  # (lib.modules.mkIf pkgs.stdenv.hostPlatform.isLinux {
  #   xdg = {
  #     enable = true;
  #     desktopEntries = {
  #       "bottom" = {
  #         name = "bottom";
  #         noDisplay = true;
  #       };
  #     };
  #   };
  # })
}
