{ pkgs, config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.json.enable =
    lib.mkEnableOption "enables json support";

  config = lib.mkIf ide.languages.json.enable {
    programs.emacs.init = {
      ide.treesitterGrammars.json5 = "https://github.com/Joakker/tree-sitter-json5";
      usePackage = {
        json-ts-mode = {
          enable = true;
          extraPackages = if ide.lsp-bridge.enable || ide.lspce.enable
                             || ide.lsp.enable || ide.eglot.enable then
                               with pkgs; [ vscode-langservers-extracted ]
                          else
                            [ ];
          mode = [ ''"\\.json\\'"'' ];
          lsp = ide.lsp.enable;
          lspce = ide.lspce.enable;
          eglot = ide.eglot.enable;
          symex = ide.symex;
          config = lib.mkIf ide.lspce.enable ''(nix-emacs-lspce-add-server-program "json" "vscode-json-language-server" "--stdio")'';
        };

        json5-ts-mode = {
          enable = true;
          extraPackages = [ pkgs.vscode-langservers-extracted ];
          mode = [ ''"\\.json5\\'"'' ];
          eglot = lib.mkIf ide.eglot.enable ''("vscode-json-language-server" "--stdio")'';
          symex = ide.symex;
          lspce = ide.lspce.enable;
          config = lib.mkIf ide.lspce.enable ''(nix-emacs-lspce-add-server-program "json5" "vscode-json-language-server" "--stdio")'';
        };
      };
    };
  };
}
