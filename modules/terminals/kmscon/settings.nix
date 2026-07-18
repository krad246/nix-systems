{
  flake.modules.nixos.kmscon = {pkgs, ...}: {
    services.kmscon = {
      fonts = [
        {
          name = "MesloLGM Nerd Font Mono";
          package = pkgs.nerd-fonts.meslo-lg;
        }
        {
          name = "Symbols Nerd Font Mono";
          package = pkgs.nerd-fonts.symbols-only;
        }
        {
          name = "Noto Emoji";
          package = pkgs.noto-fonts-monochrome-emoji;
        }
      ];
      extraConfig = ''
        font-size=16
      '';
    };
  };
}
