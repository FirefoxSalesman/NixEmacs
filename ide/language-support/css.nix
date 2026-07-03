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
  options.programs.emacs.init.ide.languages.css = {
    enable = lib.mkEnableOption "enables css support";
    emmet = lib.mkEnableOption "enables emmet for css";
  };

  config = lib.mkIf ide.languages.css.enable {
    programs.emacs.init = {
      ide = {
        treesitter.wantTreesitter = true;
        treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "css-ts-mode" ];
      };

      tools.apheleia.modeFormatters.css-ts-mode = lib.mkIf (
        config.programs.emacs.init.tools.apheleia.enable && (ide.eglot.enable || ide.lsp.enable)
      ) (lib.mkDefault (if ide.eglot.enable then "eglot" else "lsp"));

      usePackage = {
        emmet-mode = {
          enable = ide.languages.css.emmet;
          hook = [ "(css-ts-mode . emmet-mode)" ];
          setopt.emmet-move-cursor-between-quotes = lib.mkDefault true;
        };

        css-ts-mode = {
          enable = true;
          babel = lib.mkIf ide.languages.org.enable "css";
          extraPackages = lib.mkIf (
            ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable
          ) [ pkgs.vscode-css-languageserver ];
          mode = [ ''"\\.css\\'"'' ];
          eglot = ide.eglot.enable;
          symex = ide.symex;
          lsp = ide.lsp.enable;
          lspce = lib.mkIf ide.lspce.enable ''"css" "vscode-css-language-server" "--stdio"'';
        };
      };
    };
  };
}
