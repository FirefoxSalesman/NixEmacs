{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.emacs-lisp = {
    enable = lib.mkEnableOption "Enables additional support for emacs lisp. Borrowed from doom, & highly reccommended";
    hoverDoc = lib.mkEnableOption "Uses eldoc-box to give a documentation popup on hover";
    flymake = lib.mkEnableOption "Enable flymake.";
  };

  config = lib.mkIf ide.languages.emacs-lisp.enable {
    programs.emacs.init.usePackage = {
      elisp-mode = {
        enable = true;
        symex = ide.symex;
        mode = [''("\\.Cask\\'" . emacs-lisp-mode)''];
        hook = lib.mkIf ide.languages.emacs-lisp.flymake ["(emacs-lisp-mode . flymake-mode)"];
      };

      elisp-demos = {
        enable = true;
        config = ''
          (advice-add #'describe-function-1 :after #'elisp-demos-advice-describe-function-1)
          (with-eval-after-load 'helpful (advice-add #'helpful-update :after #'elisp-demos-advice-helpful-update))
        '';
      };

      highlight-quoted = {
        enable = true;
        hook = ["(emacs-lisp-mode . highlight-quoted-mode)"];
      };

      eldoc-box = lib.mkIf ide.languages.emacs-lisp.hoverDoc {
        enable = true;
        hook = ["(emacs-lisp-mode . eldoc-box-hover-at-point-mode)"];
      };
    };
  };
}
