{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [cargo rustc rust-analyzer-unwrapped];

  home.sessionVariables = {
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
  };
}
