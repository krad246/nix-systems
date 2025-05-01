{
  withSystem,
  config,
  lib,
  pkgs,
  ...
}: let
  stripComments = path:
    pkgs.runCommand "strip-comments" {} ''
      ${lib.meta.getExe' pkgs.gcc "cpp"} -P -E "${path}" > "$out"
    '';

  keybindings = stripComments ./keybindings.json;
  settings = stripComments ./settings.json;
in {
  home.packages = with pkgs;
    [nil nixd]
    ++ (withSystem pkgs.stdenv.system ({self', ...}: self'.packages.term-fonts.paths));

  programs.vscode = {
    enable = true;

    package =
      if pkgs.stdenv.isLinux
      then
        pkgs.vscode.fhsWithPackages (ps:
          withSystem ps.stdenv.system ({
            self',
            pkgs,
            ...
          }:
            self'.packages.term-fonts.paths ++ [pkgs.nil pkgs.nixd]))
      else pkgs.vscode;

    profiles.default = {
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        ms-vscode-remote.remote-containers
        sainnhe.gruvbox-material
        pkief.material-icon-theme
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
        ms-vscode-remote.remote-wsl
        MS-vsliveshare.vsliveshare
        # ms-azuretools.vscode-docker
        # ms-vscode.makefile-tools
        jnoortheen.nix-ide
        nefrob.vscode-just-syntax
      ];

      globalSnippets = {
      };

      keybindings = lib.trivial.importJSON keybindings;
      userSettings = lib.trivial.importJSON settings;

      languageSnippets = {
      };

      userTasks = {
      };
    };
    mutableExtensionsDir = false;
  };

  home.file = let
    # default storage paths on different operating systems
    userDir =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "Library/Application Support/Code/User"
      else "${config.xdg.configHome}/Code/User";
    settingsFilePath = "${userDir}/settings.json";
    keybindingsFilePath = "${userDir}/keybindings.json";
  in {
    "${userDir}/.keybindings-immutable.json" = {
      text = builtins.readFile keybindings;
      onChange = ''
        run cp $VERBOSE_ARG --preserve --remove-destination -f "$(readlink -f "${keybindingsFilePath}")" "${keybindingsFilePath}"
        verboseEcho "Regenerating VSCode keybindings.json"
      '';
    };

    "${userDir}/.settings-immutable.json" = {
      text = builtins.readFile settings;
      onChange = ''
        run cp $VERBOSE_ARG --preserve --remove-destination -f "$(readlink -f "${settingsFilePath}")" "${settingsFilePath}"
        verboseEcho "Regenerating VSCode settings.json"
      '';
    };
  };
}
