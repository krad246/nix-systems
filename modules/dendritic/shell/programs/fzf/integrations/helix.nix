{lib, ...}: {
  flake.modules.homeManager.fzf = {
    config,
    pkgs,
    ...
  }: {
    options.picker.backends.fzf.integrations.helix.enable =
      lib.options.mkEnableOption "Helix edit action for FZF";

    config.picker.actions.edit = {
      enable = lib.modules.mkDefault config.picker.backends.fzf.integrations.helix.enable;
      command = lib.modules.mkIf config.picker.backends.fzf.integrations.helix.enable (lib.modules.mkDefault (lib.meta.getExe' (pkgs.symlinkJoin {
        name = "hx";
        paths = [config.programs.helix.package];
        buildInputs = [pkgs.makeWrapper];
        postBuild = let
          stripSuspend = let
            go = value:
              if builtins.isAttrs value
              then
                lib.mapAttrs (name: nested:
                  if name == "C-z"
                  then "no_op"
                  else go nested)
                value
              else if lib.isList value
              then map go value
              else value;
          in
            go;
        in ''
          wrapProgram $out/bin/hx --add-flags '-c ${let
            tomlFormat = pkgs.formats.toml {};
          in
            tomlFormat.generate "hx-nosusp-config.toml" (stripSuspend config.programs.helix.settings)}'
        '';
      }) "hx"));
    };
  };
}
