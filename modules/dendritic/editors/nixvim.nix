{
  flake.modules.homeManager.nixvim = {pkgs, ...}: let
    inherit (pkgs.krad246) nixvim;
  in {
    home = {
      packages =
        [nixvim]
        ++ (with pkgs; [
          nil
          nixd
        ]);
    };

    # programs.bash = {
    #   shellAliases = {
    #     vi = meta.getExe nixvim;
    #     vim = meta.getExe nixvim;
    #     vimdiff = "${meta.getExe nixvim} -d";
    #   };

    #   sessionVariables = {
    #     EDITOR = meta.getExe nixvim;
    #   };
    # };
  };
}
