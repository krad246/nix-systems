{
  self,
  inputs,
  config,
  ...
}: {
  ezConfigs = {
    root = self;
    globalArgs = {inherit self inputs;};

    nixos = {
      configurationsDirectory = "${config.ezConfigs.root}/configurations/nixos";
      modulesDirectory = "${config.ezConfigs.root}/modules/nixos";
      hosts = {
        windex.userHomeModules = ["keerad" "krad246"];
        fortress.userHomeModules = ["krad246"];
      };
    };

    darwin = {
      configurationsDirectory = "${config.ezConfigs.root}/configurations/darwin";
      modulesDirectory = "${config.ezConfigs.root}/modules/darwin";
      hosts = {
        nixbook-air.userHomeModules = ["krad246"];
        nixbook-pro.userHomeModules = ["krad246"];
        dullahan.userHomeModules = ["krad246"];
      };
    };

    home = {
      configurationsDirectory = "${config.ezConfigs.root}/configurations/home";
      modulesDirectory = "${config.ezConfigs.root}/modules/home";

      users = {
        keerad = {
          # Generate only one WSL config; requires a matching Windows user
          nameFunction = _name: "keerad@windex";

          # Standalone configuration independent of the host
          standalone = let
            inherit (inputs) nixpkgs-stable;
            impure = builtins ? currentSystem;
            system =
              if impure
              then builtins.currentSystem
              else throw "Cannot build the
                standalone configuration in pure mode!";
            pkgs = import nixpkgs-stable {inherit system;};
          in {
            enable = impure;
            inherit pkgs;
          };
        };
      };
    };
  };
}
