{
  pkgs,
  config,
  ...
}: {
  # In home-manager.users.your-name-here
  age = {
    secretsDir = "${config.home.homeDirectory}/.agenix/agenix";
    secretsMountPoint = "${config.home.homeDirectory}/.agenix/agenix.d";
  };

  home.file = let
    name = "agenix-home-integration";
  in {
    ${name}.source = pkgs.writeShellApplication {
      inherit name;
      text = let
        secret = "world!";
      in ''
        diff -q "${config.age.secrets.gh.path}" <(printf '${secret}\n')
      '';
    };
  };
}
