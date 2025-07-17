{ lib, config, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.racket.enable = lib.mkEnableOption
    "Enables racket support. You will need to install the language server yourself";

  config = lib.mkIf ide.languages.racket.enable {
    programs.emacs.init.usePackage.racket-mode = {
      enable = ide.languages.scheme.racket;
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      lspce = ide.lspce.enable;
      lsp-bridge = ide.lsp-bridge.enable;
      symex = ide.symex;
      mode = [ ''"\\.rkt\\'"'' ];
      init = ''
        (setq auto-mode-alist (delete '("\\.rkt\\'" . scheme-mode) auto-mode-alist))'';
      config = ''
        (setq auto-mode-alist (delete '("\\.rkt\\'" . scheme-mode) auto-mode-alist))
        ${if ide.lspce.enable then
          ''
            (add-to-list 'lspce-server-programs '("racket" "racket" "-l racket-langserver"))''
        else
          ""}
      '';
    };
  };
}
