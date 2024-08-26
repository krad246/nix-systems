{pkgs, ...}: let
  treesitterWithGrammars =
    pkgs.vimPlugins.nvim-treesitter.withPlugins
    (p: [
      p.bash
      p.cpp
      p.comment
      p.dockerfile
      p.gitattributes
      p.gitignore
      p.json5
      p.json
      p.lua
      p.make
      p.markdown
      p.nix
      p.python
      p.rust
      p.toml
      p.yaml
    ]);
in {
  imports = [../fd.nix ../ripgrep.nix];

  home.packages = with pkgs; [nil];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    package = pkgs.neovim-unwrapped;
    coc.enable = false;
    plugins = [
      treesitterWithGrammars
    ];
  };

  home = {
    file."./.config/nvim/" = {
      source = ./.;
      recursive = true;
    };

    # Treesitter is configured as a locally developed module in lazy.nvim
    # we hardcode a symlink here so that we can refer to it in our lazy config
    file."./.local/share/nvim/nix/nvim-treesitter/" = {
      recursive = true;
      source = treesitterWithGrammars;
    };
  };
}
