{
  lib,
  pkgs,
  ...
}: {
  programs.helix = {
    enable = true;
    package = pkgs.evil-helix;
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
        evil = true;
      };
    };
  };
}
