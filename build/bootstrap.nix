{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    apps = {
      bootstrap = let
        runner = pkgs.writeShellApplication {
          name = "bootstrap";
          runtimeInputs = with pkgs; [git];
          text = ''
            allow() {
                ${lib.getExe pkgs.git} config --global --add safe.directory "$1"
                ${lib.getExe pkgs.git} config --global --add safe.directory "$1/.git"
            }

            readme() {
                :
            }

            readme && allow "$PWD" && exec ${lib.getExe pkgs.nix} develop
          '';
        };
      in {
        type = "app";
        program = lib.getExe runner;
        meta.description = "Run the devShell bootstrap script.";
      };
    };
  };
}
