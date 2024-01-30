{
  perSystem = {pkgs, ...}: let
    mkScript = {
      name,
      src,
      ...
    }: let
      addMeta = old: {meta.mainProgram = "${old.meta.mainProgram}";};
      wrapper = pkgs.writeShellScriptBin name src;
    in
      wrapper.overrideAttrs addMeta;

    mkTool = args @ {
      name,
      entrypoint,
      ...
    }: {
      ${name} = let
        script = mkScript {
          inherit name;
          src = builtins.readFile entrypoint;
        };
        patcher = old: {buildCommand = "${old.buildCommand}\n patchShebangs $out";};
        exec = script.overrideAttrs patcher;
      in {
        description = args.description or "run ${entrypoint}";
        inherit exec;
      };
    };
  in {
    mission-control.scripts =
      (mkTool {
        name = "clean";
        entrypoint = ./bash/clean.bash;
      })
      // (mkTool {
        name = "add";
        entrypoint = ./bash/add.bash;
      })
      // (mkTool {
        name = "check";
        entrypoint = ./bash/check.bash;
      })
      // (mkTool {
        name = "edit";
        entrypoint = ./bash/edit.bash;
      })
      // (mkTool {
        name = "fmt";
        entrypoint = ./bash/fmt.bash;
      })
      // (mkTool {
        name = "purge";
        entrypoint = ./bash/purge.bash;
      });
  };
}
