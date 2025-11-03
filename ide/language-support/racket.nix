{ lib, config, ... }:

let
  ide = config.programs.emacs.init.ide;
  completions = config.programs.emacs.init.completions;
in
{
  options.programs.emacs.init.ide.languages.racket.enable =
    lib.mkEnableOption "Enables racket support. You will need to install the language server yourself";

  config = lib.mkIf ide.languages.racket.enable {
    programs.emacs.init = {
      completions.tempel.templates.racket-mode = {
        "let" = ''"(let [(" p ")]" n q ")"'';
        letrec = ''"(letrec [(" p ")]" n q ")"'';
        letstar = ''"(let* [(" p ")]" n q ")"'';
        namelet = ''"(let " p " [(" p ")]" n q ")"'';
        defun = ''"(define " p " (lambda (" p ")" n q "))"'';
      };
      usePackage.racket-mode = {
        enable = ide.languages.scheme.racket;
        eglot = ide.eglot.enable;
        lsp = ide.lsp.enable;
        lspce = lib.mkIf ide.lspce.enable ''"racket" "racket" "-l racket-langserver"'';
        symex = ide.symex;
        mode = [ ''"\\.rkt\\'"'' ];
        init = ''(setq auto-mode-alist (delete '("\\.rkt\\'" . scheme-mode) auto-mode-alist))'';
        config = ''(setq auto-mode-alist (delete '("\\.rkt\\'" . scheme-mode) auto-mode-alist))'';
        generalTwoConfig.local-leader.racket-mode-map =
          lib.mkIf config.programs.emacs.init.keybinds.leader-key.enable
            {
              "." = lib.mkDefault "'racket-xp-describe";
              "r" = lib.mkDefault "'racket-run";
            };
      };
    };
  };
}
