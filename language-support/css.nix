{ pkgs, config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.css = {
    enable = lib.mkEnableOption "enables css support";
    emmet = lib.mkEnableOption "enables emmet for css";
  };

  config = lib.mkIf ide.languages.css.enable {
    programs.emacs.init.usePackage = {
      emmet-mode = {
        enable = ide.css.emmet;
        hook = [ "(css-ts-mode . emmet-mode)" ];
        custom.emmet-move-cursor-between-quotes = lib.mkDefault true;
      };

      css-ts-mode = {
        enable = true;
        extraPackages = if ide.lsp-bridge.enable || ide.lspce.enable
        || ide.lsp.enable || ide.eglot.enable then
          with pkgs; [ vscode-langservers-extracted ]
        else
          [ ];
        mode = [ ''"\\.css\\'"'' ];
        eglot = ide.eglot.enable;
        symex = ide.symex;
        lsp = ide.lsp.enable;
        lspce = ide.lspce.enable;
        config = lib.mkIf ide.lspce.enable ''
          (with-eval-after-load 'lspce (add-to-list 'lspce-server-programs (list "css" "vscode-css-language-server" "--stdio"))
        '';
      };
    };
  };
}
