{
  flake.modules.homeManager.helix = {pkgs, ...}: {
    programs.helix = {
      extraPackages = with pkgs; [
        bash-language-server
        clang-tools
        just-lsp
        marksman
        neocmakelsp
        nixd
        yaml-language-server
      ];

      languages = {
        language-server = {
          bash-language-server = {
            command = "bash-language-server";
            args = ["start"];
          };
          clangd.command = "clangd";
          docker-langserver = {
            command = "docker-language-server";
            args = ["start"];
          };
          just-lsp.command = "just-lsp";
          marksman = {
            command = "marksman";
            args = ["server"];
          };
          neocmakelsp = {
            command = "neocmakelsp";
            args = ["stdio"];
          };
          nixd.command = "nixd";
          yaml-language-server = {
            command = "yaml-language-server";
            args = ["--stdio"];
          };
        };

        languages = {
          language = [
            {
              name = "bash";
              language-servers = ["bash-language-server"];
            }
            {
              name = "c";
              language-servers = ["clangd"];
            }
            {
              name = "cpp";
              language-servers = ["clangd"];
            }
            {
              name = "cmake";
              language-servers = ["neocmakelsp"];
            }
            {
              name = "just";
              language-servers = ["just-lsp"];
            }
            {
              name = "markdown";
              language-servers = ["marksman"];
            }
            {
              name = "nix";
              language-servers = ["nixd"];
              # formatter = {
              #   command = meta.getExe pkgs.alejandra;
              # };
            }
            # {
            #   name = "python";
            #   language-servers = [];
            # }
            {
              name = "yaml";
              language-servers = ["yaml-language-server"];
            }
          ];
        };
      };
    };
  };
}
