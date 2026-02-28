{
  flake.modules.homeManager.ripgrep = {
    config,
    lib,
    ...
  }: let
    cfg = config.shell.programs.ripgrep;
  in {
    imports = [
      (
        lib.modules.mkAliasOptionModule
        ["shell" "programs" "ripgrep" "enable"]
        ["programs" "ripgrep" "enable"]
      )
    ];

    programs = {
      ripgrep = {
        # TODO: shim rga in as rg
        # package = pkgs.symlinkJoin {
        #   name = "ripgrep-all-wrapper";
        #   paths = [ config.programs.ripgrep-all.package ];
        #   nativeBuildInputs = [ pkgs.makeWrapper ];
        #   postFixup = ''
        #     makeWrapper $out/bin/rga $out/bin/rg --inherit-argv0
        #   '';
        # };

        arguments = [
        ];
      };

      ripgrep-all = lib.modules.mkIf cfg.enable {
        enable = true;
        custom_adapters = [
        ];
      };
    };
  };
}
