{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.apps.zen-browser;
in {
  options = {
    krad246.darwin.apps.zen-browser = lib.options.mkEnableOption "zen-browser" // {default = true;};
  };

  config = {
    homebrew = {
      casks = lib.modules.mkIf cfg ["zen"];
    };

    home-manager.sharedModules = lib.lists.optionals cfg [
      ({
        config,
        lib,
        pkgs,
        modulesPath,
        ...
      }: {
        manual.html.enable = lib.modules.mkForce false;

        home.packages = let
          docsPath = modulesPath + "/../docs";

          docs = import docsPath {
            inherit lib pkgs;
            inherit (config.home.version) release isReleaseBranch;
          };

          htmlOpenTool = pkgs.symlinkJoin {
            name = "home-manager";
            paths = [docs.manual.htmlOpenTool];
            buildInputs = [pkgs.makeWrapper];
            postBuild = let
              opener = pkgs.writeShellApplication {
                name = "zen-browser-file-open";
                text = ''
                  open -a Zen -u "file://$1"
                '';
              };
            in ''
              wrapProgram $out/bin/home-manager-help --set BROWSER ${lib.meta.getExe opener}
            '';
          };
        in
          with pkgs; (with docs.manual; [
            html
            htmlOpenTool
          ]);
      })
    ];
  };
}
