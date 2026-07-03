{
  pkgs,
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.json.enable = lib.mkEnableOption "enables json support";

  config = lib.mkIf ide.languages.json.enable {
    programs.emacs.init = {
      ide = {
        treesitter.treesitterGrammars.json5 = "https://github.com/Joakker/tree-sitter-json5";
        treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [
          "json-ts-mode"
          "json5-ts-mode"
        ];
      };
      usePackage = {
        json-ts-mode = {
          enable = true;
          extraPackages = lib.mkIf (
            ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable
          ) [ pkgs.vscode-json-languageserver ];
          mode = [ ''"\\.json\\'"'' ];
          lsp = ide.lsp.enable;
          eglot = ide.eglot.enable;
          symex = ide.symex;
          lspce = lib.mkIf ide.lspce.enable ''"json" "vscode-json-language-server" "--stdio"'';
        };

        json5-ts-mode = {
          enable = true;
          mode = [ ''"\\.json5\\'"'' ];
          eglot = lib.mkIf ide.eglot.enable ''("vscode-json-language-server" "--stdio")'';
          symex = ide.symex;
          lspce = lib.mkIf ide.lspce.enable ''"json5" "vscode-json-language-server" "--stdio"'';
        };
      };
    };
  };
}
