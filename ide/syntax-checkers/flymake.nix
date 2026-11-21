{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.flymake.preset =
    lib.mkEnableOption "Enables flymake's preset configuraiton.";

  config = lib.mkIf ide.flymake.preset {
    programs.emacs.init.usePackage = {
      flymake = {
        enable = true;
        defer = true;
        setopt.flymake-indicator-position = "'right-fringe";
        hook = lib.mkIf ide.languages.emacs-lisp.enable [
          {
            names = [ "flymake-mode" ];
            actions = [
              ''
                (lambda () (when (major-mode? 'emacs-lisp-mode)
                            (setq-local eldoc-documentation-functions
                	                '(elisp-eldoc-var-docstring elisp-eldoc-funcall t))))''
            ];
          }
        ];
        config = lib.mkIf config.programs.emacs.init.keybinds.evil.enable ''(evil-ex-define-cmd "trouble" 'flymake-show-project-diagnostics)'';
      };

      flymake-popon = lib.mkIf (ide.hoverDoc && !ide.flycheck.preset) {
        enable = true;
        setopt.flymake-popon-method = "'posframe";
        hook = [
          {
            names = [ "flymake-mode" ];
            actions = [ "'flymake-popon-mode" ];
          }
        ];
      };

      eglot.hook = lib.mkIf ide.eglot.preset [
        {
          names = [ "eglot-managed-mode" ];
          actions = [
            ''
              (lambda () (setq-local eldoc-documentation-functions '(eglot-signature-eldoc-function
                                                                       eglot-hover-eldoc-function
                                                                       t
                                                                       eglot-x-hover-eldoc-function)))''
          ];
        }
      ];
    };
  };
}
