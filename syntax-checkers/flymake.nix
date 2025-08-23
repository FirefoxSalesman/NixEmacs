{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.flymake.preset = lib.mkEnableOption "Enables flymake's preset configuraiton.";

  config = lib.mkIf ide.flymake.preset {
    programs.emacs.init.usePackage = {
      flymake = {
        enable = true;
        custom.flymake-indicator-position = "'right-fringe";
        hook = lib.mkIf ide.languages.emacs-lisp.enable [''(flymake-mode . (lambda () (when (eq major-mode 'emacs-lisp-mode)
                                                                                            (setq-local eldoc-documentation-functions '(elisp-eldoc-var-docstring
                                                                                                                                        elisp-eldoc-funcall
                                                                                                                                        t)))))''
       ];
      };

      flymake-swi-prolog = lib.mkIf (ide.languages.prolog.enable && ide.flymake.enable) {
        enable = true;
        after = ["prolog-mode"]; 
        hook = ["(prolog-mode . flymake-mode)"];
      };

      flymake-popon = lib.mkIf (ide.hoverDoc && !ide.flycheck.preset) {
        enable = true;
        custom.flymake-popon-method = "'posframe";
        hook = ["(flymake-mode . flymake-popon-mode)"];
      };

      flyover.hook = lib.mkIf ide.flycheck.preset ["(flymake-mode . flyover-mode)"];

      eglot.hook = lib.mkIf ide.eglot.preset [''(eglot-managed-mode . (lambda () (setq-local eldoc-documentation-functions '(eglot-signature-eldoc-function
                                                                                                                             eglot-hover-eldoc-function
                                                                                                                             t
                                                                                                                             eglot-x-hover-eldoc-function))))''];
    };
  };
}
