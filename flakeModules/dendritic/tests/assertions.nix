{
  config,
  lib,
  ...
}: let
  flakeConfig = config;
in {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    options.dendritic = {
      assertions = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            assertion = lib.mkOption {
              type = lib.types.bool;
              description = "Assertion condition.";
            };
            message = lib.mkOption {
              type = lib.types.str;
              description = "Message shown when the assertion fails.";
            };
          };
        });
        default = [];
        description = "Debug-only assertions contributed by Dendritic test modules.";
      };

      warnings = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Debug-only warnings contributed by Dendritic test modules.";
      };

      traces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Debug-only trace messages contributed by Dendritic test modules.";
      };
    };

    config.checks = lib.mkIf flakeConfig.debug {
      dendritic-assertions = let
        failures = map (assertion: assertion.message) (
          lib.filter (assertion: !assertion.assertion) config.dendritic.assertions
        );
        checked =
          if failures == []
          then pkgs.emptyDirectory
          else
            throw ''
              Failed Dendritic assertions:
              ${lib.concatMapStringsSep "\n" (message: "- ${message}") failures}
            '';
        warned = lib.foldr lib.warn checked config.dendritic.warnings;
      in
        lib.foldr builtins.trace warned config.dendritic.traces;
    };
  };
}
