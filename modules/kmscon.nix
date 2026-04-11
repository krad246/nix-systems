{
  flake.modules.nixos.kmscon = {pkgs, ...}: {
    services.kmscon = {
      enable = true;
      fonts = [
        {
          name = "MesloLGM Nerd Font Mono";
          package = pkgs.nerd-fonts.meslo-lg;
        }
        {
          name = "Symbols Nerd Font Mono";
          package = pkgs.nerd-fonts.symbols-only;
        }
        # {
        #   name = "Noto Color Emoji";
        #   package = pkgs.noto-fonts-color-emoji;
        # }
        {
          name = "Noto Emoji";
          package = pkgs.noto-fonts-monochrome-emoji;
        }
        # {
        #   name = "Twitter Color Emoji";
        #   package = pkgs.twemoji-color-font;
        # }
      ];
      extraConfig = ''
        font-size=16
      '';
    };
  };
}
