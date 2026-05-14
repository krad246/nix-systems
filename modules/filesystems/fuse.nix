{
  flake.modules = {
    darwin.fuse = {
      homebrew.casks = ["macfuse"];
    };

    nixos.fuse = {
      programs.fuse.enable = true;
    };
  };
}
