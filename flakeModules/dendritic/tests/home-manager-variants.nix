{
  config,
  inputs,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    homeManager = rec {
      baseConfiguration = root:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          inherit (root) modules;
        };

      configuration = policy: root: let
        evaluated = baseConfiguration root;
        includedSpecialisations = lib.filterAttrs (_: variant:
          if variant.includeSpecialisations != null
          then variant.includeSpecialisations
          else policy.includeSpecialisations)
        root.variants;
      in
        if includedSpecialisations == {}
        then evaluated
        else
          evaluated.extendModules {
            modules = [
              {
                specialisation =
                  lib.mapAttrs (_: variant: {
                    configuration.imports = variant.modules;
                  })
                  includedSpecialisations;
              }
            ];
          };

      outputs = policy: roots:
        lib.pipe roots [
          (lib.mapAttrsToList (rootName: root:
            [{${rootName} = configuration policy root;}]
            ++ lib.pipe root.variants [
              (lib.filterAttrs (_: variant:
                if variant.build != null
                then variant.build
                else policy.build))
              (lib.mapAttrsToList (variantName: variant: {
                "${rootName}-${variantName}" = (baseConfiguration root).extendModules {inherit (variant) modules;};
              }))
            ]))
          lib.concatLists
          (lib.foldl' (outputs: output: outputs // output) {})
        ];
    };

    declaration = _: {
      modules = [
        {
          home = {
            username = "variant-test";
            homeDirectory = "/home/variant-test";
            stateVersion = "25.11";
          };
        }
      ];
      variants.dev = {
        modules = [{home.sessionVariables.DENDRITIC_VARIANT = "dev";}];
        build = null;
        includeSpecialisations = null;
      };
    };

    outputsFor = policy:
      homeManager.outputs policy {
        standalone = declaration policy;
      };

    neither = outputsFor {
      build = false;
      includeSpecialisations = false;
    };
    standaloneOnly = outputsFor {
      build = true;
      includeSpecialisations = false;
    };
    includedOnly = outputsFor {
      build = false;
      includeSpecialisations = true;
    };
    both = outputsFor {
      build = true;
      includeSpecialisations = true;
    };
    includedDev = outputs:
      outputs.standalone.config.specialisation.dev.configuration;

    productionStandalone = homeManager.baseConfiguration {
      modules = config.dendritic.configurations.users.standalone.modules ++ config.dendritic.configurations.users.standalone.standalone.modules;
    };
    productionNixbook = homeManager.baseConfiguration {
      modules = config.dendritic.configurations.users.krad246.modules ++ config.dendritic.configurations.users.krad246.standalone.modules;
    };
    legacyConfiguration = inputs.dendritic.darwinConfigurations.nixbook-pro;
    legacyConfig = legacyConfiguration.config;
    legacy = legacyConfig.home-manager.users.${legacyConfig.owner.username};
    composedConfiguration = config.flake.darwinConfigurations.nixbook-pro-composed;
    composedConfig = composedConfiguration.config;
    composed = composedConfig.home-manager.users.${composedConfig.owner.username};
  in {
    dendritic.assertions = [
      {
        assertion = builtins.attrNames neither == ["standalone"];
        message = "disabled standalone variants emit only the root configuration";
      }
      {
        assertion = neither.standalone.config.specialisation == {};
        message = "disabled inclusion leaves the standalone root unspecialised";
      }
      {
        assertion = builtins.attrNames standaloneOnly == ["standalone" "standalone-dev"];
        message = "standalone variants expose lightweight configuration handles";
      }
      {
        assertion = standaloneOnly.standalone.config.specialisation == {};
        message = "a standalone variant is not implicitly included as a specialisation";
      }
      {
        assertion = standaloneOnly.standalone-dev ? extendModules;
        message = "standalone variants retain the normal Home Manager result interface";
      }
      {
        assertion = standaloneOnly.standalone-dev.config.home.sessionVariables.DENDRITIC_VARIANT == "dev";
        message = "the standalone variant contains its module delta";
      }
      {
        assertion = builtins.attrNames includedOnly == ["standalone"];
        message = "specialisation inclusion alone does not emit a standalone variant";
      }
      {
        assertion = (includedDev includedOnly).home.sessionVariables.DENDRITIC_VARIANT == "dev";
        message = "inclusion embeds the variant delta in Home Manager specialisations";
      }
      {
        assertion = builtins.attrNames both == ["standalone" "standalone-dev"];
        message = "standalone output and specialisation inclusion may be selected together";
      }
      {
        assertion = both.standalone-dev.activationPackage.drvPath == (includedDev both).home.activationPackage.drvPath;
        message = "standalone and included views resolve the same activation derivation";
      }
      {
        assertion = system != "aarch64-darwin" || composed.home.username == legacy.home.username;
        message = "the composed nixbook-pro user retains the legacy username";
      }
      {
        assertion = system != "aarch64-darwin" || productionNixbook.config.home.homeDirectory == legacy.home.homeDirectory;
        message = "the standalone nixbook-pro user retains the legacy home directory";
      }
      {
        assertion = system != "aarch64-darwin" || map toString composed.home.packages == map toString legacy.home.packages;
        message = "the composed nixbook-pro package closure matches legacy";
      }
      {
        assertion = system != "aarch64-darwin" || map (package: package.name) (lib.filter (package: package.name != "home-manager") productionNixbook.config.home.packages) == map (package: package.name) legacy.home.packages;
        message = "the standalone nixbook-pro package inventory matches legacy apart from its owned Home Manager CLI";
      }
      {
        assertion = system != "aarch64-darwin" || builtins.attrNames composed.home.file == builtins.attrNames legacy.home.file;
        message = "the composed nixbook-pro managed-file inventory matches legacy";
      }
      {
        assertion = system != "aarch64-darwin" || builtins.attrNames productionNixbook.config.xdg.configFile == builtins.attrNames legacy.xdg.configFile;
        message = "the standalone nixbook-pro XDG-file inventory matches legacy";
      }
      {
        assertion = system != "aarch64-darwin" || removeAttrs productionNixbook.config.home.sessionVariables ["TERMINFO_DIRS"] == removeAttrs legacy.home.sessionVariables ["TERMINFO_DIRS"];
        message = "the standalone nixbook-pro session matches legacy apart from profile-owned terminfo paths";
      }
      {
        assertion = productionStandalone.config.home.username == "krad246";
        message = "the portable standalone user retains its configured identity";
      }
    ];
  };
}
