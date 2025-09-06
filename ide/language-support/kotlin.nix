{
  pkgs,
  config,
  lib,
  ...
}:
# This module is blatantly stolen from doom emacs

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.kotlin.enable =
    lib.mkEnableOption "enables kotlin support";

  config = lib.mkIf ide.languages.kotlin.enable {
    programs.emacs.init = {
      ide.treesitterGrammars.kotlin = "https://github.com/fwcd/tree-sitter-kotlin";
      usePackage = {
        kotlin-ts-mode = {
          enable = true;
          mode = [ ''"\\.kt\\'"'' ];
          extraPackages =
            if ide.eglot.enable || ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable then
              [ pkgs.kotlin-language-server ]
            else
              [ ];
          symex = ide.symex;
          eglot = ide.eglot.enable;
          lsp = ide.lsp.enable;
          # Kotlin's language server takes a very long time to initialize on a new project
          # https://github.com/fwcd/kotlin-language-server/issues/510
          custom.eglot-connect-timeout = lib.mkIf ide.eglot.enable (lib.mkDefault 999999);
          lspce = lib.mkIf ide.lspce.enable ''"kotlin" "kotlin-language-server"'';
        };

        ob-kotlin = lib.mkIf ide.languages.org.enable {
          enable = true;
          babel = lib.mkIf ide.languages.org.enable "kotlin";
        };
      };
    };
  };
}
