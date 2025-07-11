{ pkgs, lib, config, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.racket.enable = lib.mkEnableOption "Enables racket support. You will need to install the language server yourself";

  config = lib.mkIf ide.languages.racket.enable {
    programs.emacs.init.usePackage.racket-mode = {
      enable = ide.languages.scheme.racket;
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      symex = ide.symex;
      mode = [''"\\.rkt\\'"''];
      init = ''(setq auto-mode-alist (delete '("\\.rkt\\'" . scheme-mode) auto-mode-alist))'';
      config = ''(setq auto-mode-alist (delete '("\\.rkt\\'" . scheme-mode) auto-mode-alist))'';
    };
  };
}
