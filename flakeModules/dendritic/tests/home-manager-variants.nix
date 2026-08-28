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
    inheritPolicy = local: parent: global:
      if local != null
      then local
      else if parent != null
      then parent
      else global;

    resolve = policy:
      lib.mapAttrs (_: root:
        root
        // {
          variants = lib.mapAttrs (_: variant:
            variant
            // {
              publish = inheritPolicy variant.publish root.publish policy.publish;
              includeSpecialisation = inheritPolicy variant.includeSpecialisation root.includeSpecialisation policy.includeSpecialisation;
            })
          root.variants;
        });

    bare = root:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        inherit (root) modules;
      };

    configuration = root: let
      evaluated = bare root;
      embedded = lib.filterAttrs (_: variant: variant.includeSpecialisation) root.variants;
    in
      if embedded == {}
      then evaluated
      else
        evaluated.extendModules {
          modules = [
            {
              specialisation =
                lib.mapAttrs (_: delta: {
                  configuration.imports = delta.modules;
                })
                embedded;
            }
          ];
        };

    variant = root: delta:
      (bare root).extendModules {inherit (delta) modules;};

    definitions = roots:
      lib.pipe roots [
        (lib.mapAttrsToList (rootName: root:
          [{${rootName} = configuration root;}]
          ++ lib.mapAttrsToList (variantName: delta: {
            "${rootName}-${variantName}" = variant root delta;
          }) (lib.filterAttrs (_: delta: delta.publish) root.variants)))
        lib.concatLists
        (lib.foldl' (outputs: output: outputs // output) {})
      ];

    declaration = {
      publish,
      includeSpecialisation,
    }: {
      inherit publish includeSpecialisation;
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
        publish = null;
        includeSpecialisation = null;
      };
    };

    outputsFor = policy:
      definitions (resolve policy {
        standalone = declaration policy;
      });

    neither = outputsFor {
      publish = false;
      includeSpecialisation = false;
    };
    publishOnly = outputsFor {
      publish = true;
      includeSpecialisation = false;
    };
    embedOnly = outputsFor {
      publish = false;
      includeSpecialisation = true;
    };
    both = outputsFor {
      publish = true;
      includeSpecialisation = true;
    };
    embeddedDev = outputs:
      outputs.standalone.config.specialisation.dev.configuration;

    productionStandalone = bare (removeAttrs config.dendritic.configurations.standalone.users ["enable"]);
    productionNixbook = bare (removeAttrs config.dendritic.configurations.nixbook-pro.users ["enable"]);
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
        message = "disabled publication emits only the standalone root";
      }
      {
        assertion = neither.standalone.config.specialisation == {};
        message = "disabled inclusion leaves the standalone root unspecialised";
      }
      {
        assertion = builtins.attrNames publishOnly == ["standalone" "standalone-dev"];
        message = "publication exposes a lightweight standalone variant handle";
      }
      {
        assertion = publishOnly.standalone.config.specialisation == {};
        message = "publication does not implicitly embed the variant";
      }
      {
        assertion = publishOnly.standalone-dev ? extendModules;
        message = "published variants retain the normal Home Manager result interface";
      }
      {
        assertion = publishOnly.standalone-dev.config.home.sessionVariables.DENDRITIC_VARIANT == "dev";
        message = "the published variant contains its module delta";
      }
      {
        assertion = builtins.attrNames embedOnly == ["standalone"];
        message = "inclusion alone does not publish a variant handle";
      }
      {
        assertion = (embeddedDev embedOnly).home.sessionVariables.DENDRITIC_VARIANT == "dev";
        message = "inclusion embeds the variant delta in Home Manager specialisations";
      }
      {
        assertion = builtins.attrNames both == ["standalone" "standalone-dev"];
        message = "publication and inclusion may be selected together";
      }
      {
        assertion = both.standalone-dev.activationPackage.drvPath == (embeddedDev both).home.activationPackage.drvPath;
        message = "published and embedded views resolve the same activation derivation";
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
