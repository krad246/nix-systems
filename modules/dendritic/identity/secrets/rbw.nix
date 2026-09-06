{lib, ...}: {
  flake.modules.homeManager.rbw = {
    config,
    pkgs,
    ...
  }: {
    options.identity.secrets.backends.rbw.enable =
      lib.options.mkEnableOption "rbw secret-retrieval backend";

    config.programs.rbw = lib.modules.mkIf config.identity.secrets.backends.rbw.enable {
      enable = true;
      package = pkgs.rbw;
      settings = {
        inherit (config.identity.person) email;
        pinentry =
          if pkgs.stdenv.hostPlatform.isDarwin
          then pkgs.pinentry_mac
          else pkgs.pinentry-curses;
      };
    };
  };
}
