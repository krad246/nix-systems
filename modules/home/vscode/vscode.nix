{
  withSystem,
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  # default storage paths on different operating systems
  userDir =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/Application Support/Code/User"
    else "${config.xdg.configHome}/Code/User";
  settingsFilePath = "${userDir}/settings.json";
  keybindingsFilePath = "${userDir}/keybindings.json";
in {
  home.packages = with pkgs;
    [nil nixd]
    ++ [
      (withSystem pkgs.stdenv.system ({self', ...}: self'.packages.term-fonts))
    ];

  programs.vscode = let
    importJSON = x: let
      dirOffs = offs: (lib.path.removePrefix /. (/. + offs));
      assetPath = offs:
        builtins.concatStringsSep "/" [
          self
          (lib.path.subpath.join ["assets" (dirOffs offs)])
        ];

      stripComments = path:
        pkgs.runCommand "strip-comments" {} ''
          ${lib.meta.getExe' pkgs.gcc "cpp"} -P -E "${path}" > "$out"
        '';
    in
      lib.trivial.importJSON (stripComments (assetPath x));
  in {
    enable = true;

    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;

    package =
      if pkgs.stdenv.isLinux
      then
        pkgs.vscode.fhsWithPackages (ps:
          withSystem ps.stdenv.system ({
            self',
            pkgs,
            ...
          }:
            [self'.packages.term-fonts] ++ [pkgs.nil pkgs.nixd]))
      else pkgs.vscode;

    extensions = with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-containers
      sainnhe.gruvbox-material
      pkief.material-icon-theme
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
      ms-vscode-remote.remote-wsl
      # ms-azuretools.vscode-docker
      # ms-vscode.makefile-tools
      jnoortheen.nix-ide
      nefrob.vscode-just-syntax
    ];

    globalSnippets = {
    };

    keybindings = importJSON keybindingsFilePath;
    userSettings = importJSON settingsFilePath;

    languageSnippets = {
    };

    mutableExtensionsDir = true;

    userTasks = {
    };
  };
}
