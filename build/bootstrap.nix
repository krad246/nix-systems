{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    apps = rec {
      default = bootstrap;
      bootstrap = let
        runner = pkgs.writeShellApplication {
          name = "bootstrap";
          runtimeInputs = with pkgs; [git gum];
          text = ''
            allow() {
                git config --global --add safe.directory "$1"
                git config --global --add safe.directory "$1/.git"
            }

            readme() {
                :
            }

            readme && allow "$PWD" && exec nix develop
          '';
        };
      in {
        type = "app";
        program = lib.getExe runner;
      };
    };
  };
}
