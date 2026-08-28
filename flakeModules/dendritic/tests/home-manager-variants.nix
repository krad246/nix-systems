let
  flake = builtins.getFlake (toString ../../..);
  inherit (flake.inputs.nixpkgs) lib;
  pkgs = flake.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
  materialize = makeMaterialize {
    construct = context: declaration:
      flake.inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = context;
        inherit (declaration) modules;
      };
    includeSpecialisation = root: specialisations:
      root.extendModules {
        modules = [
          {
            specialisation =
              lib.mapAttrs (_: delta: {
                configuration.imports = delta.modules;
              })
              specialisations;
          }
        ];
      };
  };
  makeMaterialize = {
    construct,
    includeSpecialisation ? null,
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
    bare = context: root: construct context root;
    configuration = context: root: let
      evaluated = bare context root;
      embedded = lib.filterAttrs (_: variant: variant.includeSpecialisation) root.variants;
    in
      if embedded == {}
      then evaluated
      else if includeSpecialisation == null
      then throw "this configuration backend does not support embedded variants"
      else includeSpecialisation evaluated embedded;
    variant = context: root: delta:
      (bare context root).extendModules {inherit (delta) modules;};
  in {
    inherit configuration resolve variant;
    definitions = context: nameFunction: roots:
      lib.concatLists (lib.mapAttrsToList (rootName: root:
        [{${rootName} = configuration context root;}]
        ++ lib.mapAttrsToList (variantName: delta: {
          ${nameFunction rootName variantName} = variant context root delta;
        })
        (lib.filterAttrs (_: delta: delta.publish) root.variants))
      roots);
  };
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
          stateVersion = lib.trivial.release;
        };
      }
    ];
    variants.dev = {
      modules = [{home.sessionVariables.DENDRITIC_VARIANT = "dev";}];
      publish = null;
      includeSpecialisation = null;
    };
  };

  nameFunction = configuration: variant: "${configuration}-${variant}";

  outputsForDeclaration = root:
    (lib.evalModules {
      modules = [
        {
          options.outputs = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            default = {};
          };
        }
        {
          outputs = lib.mkMerge (materialize.definitions pkgs nameFunction (materialize.resolve {
              publish = false;
              includeSpecialisation = false;
            } {
              standalone = root;
            }));
        }
      ];
    }).config.outputs;

  outputsFor = policy: outputsForDeclaration (declaration policy);

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
  leafEnabled = outputsForDeclaration (lib.recursiveUpdate
    (declaration {
      publish = false;
      includeSpecialisation = false;
    })
    {
      variants.dev.publish = true;
      variants.dev.includeSpecialisation = true;
    });

  inherited =
    materialize.resolve {
      publish = true;
      includeSpecialisation = false;
    } {
      standalone = declaration {
        publish = null;
        includeSpecialisation = null;
      };
    };

  collision =
    builtins.tryEval
    (lib.evalModules {
      modules = [
        {
          options.outputs = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            default = {};
          };
        }
        {
          outputs = lib.mkMerge (materialize.definitions pkgs nameFunction (materialize.resolve {
              publish = true;
              includeSpecialisation = false;
            } {
              standalone = declaration {
                publish = null;
                includeSpecialisation = null;
              };
              standalone-dev = declaration {
                publish = false;
                includeSpecialisation = false;
              };
            }));
        }
      ];
    }).config.outputs.standalone-dev.activationPackage.drvPath;

  embeddedDev = outputs:
    outputs.standalone.config.specialisation.dev.configuration;

  publicationTests = let
    publicationOnly = makeMaterialize {
      construct = context: root:
        flake.inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = context;
          inherit (root) modules;
        };
    };
    unsupportedDeclaration =
      (publicationOnly.resolve {
          publish = false;
          includeSpecialisation = false;
        } {
          standalone = declaration {
            publish = false;
            includeSpecialisation = true;
          };
        }).standalone;
    supportedDeclaration =
      (publicationOnly.resolve {
          publish = true;
          includeSpecialisation = false;
        } {
          standalone = declaration {
            publish = null;
            includeSpecialisation = null;
          };
        }).standalone;
  in {
    unsupportedEmbedding = builtins.tryEval (publicationOnly.configuration pkgs unsupportedDeclaration).activationPackage.drvPath;
    supportedPublication = publicationOnly.variant pkgs supportedDeclaration supportedDeclaration.variants.dev;
  };
in
  assert builtins.attrNames neither == ["standalone"];
  assert neither.standalone.config.specialisation == {};
  assert builtins.attrNames publishOnly == ["standalone" "standalone-dev"];
  assert publishOnly.standalone.config.specialisation == {};
  assert publishOnly.standalone-dev ? activationPackage;
  assert publishOnly.standalone-dev ? config;
  assert publishOnly.standalone-dev ? extendModules;
  assert publishOnly.standalone-dev.config.home.sessionVariables.DENDRITIC_VARIANT == "dev";
  assert builtins.attrNames embedOnly == ["standalone"];
  assert (embeddedDev embedOnly).home.sessionVariables.DENDRITIC_VARIANT == "dev";
  assert builtins.attrNames both == ["standalone" "standalone-dev"];
  assert both.standalone-dev ? extendModules;
  assert both.standalone-dev.config.home.sessionVariables.DENDRITIC_VARIANT == "dev";
  assert (embeddedDev both).home.sessionVariables.DENDRITIC_VARIANT == "dev";
  assert both.standalone-dev.activationPackage.drvPath == (embeddedDev both).home.activationPackage.drvPath;
  assert builtins.attrNames leafEnabled == ["standalone" "standalone-dev"];
  assert leafEnabled.standalone-dev ? extendModules;
  assert (embeddedDev leafEnabled).home.sessionVariables.DENDRITIC_VARIANT == "dev";
  assert inherited.standalone.variants.dev.publish;
  assert !inherited.standalone.variants.dev.includeSpecialisation;
  assert !publicationTests.unsupportedEmbedding.success;
  assert publicationTests.supportedPublication.config.home.sessionVariables.DENDRITIC_VARIANT == "dev";
  assert !collision.success; true
