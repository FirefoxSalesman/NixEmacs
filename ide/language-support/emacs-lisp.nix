{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.emacs-lisp.enable =
    lib.mkEnableOption "Enables additional support for emacs lisp. Borrowed from doom, & highly reccommended";

  config.programs.emacs.init = lib.mkIf ide.languages.emacs-lisp.enable {
    ide = {
      treesitter.treesitterGrammars."elisp" =
        lib.mkIf ide.symex "https://github.com/Wilfred/tree-sitter-elisp";
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "emacs-lisp-mode" ];
    };
    usePackage = {
      elisp-mode = {
        enable = true;
        babel = lib.mkIf ide.languages.org.enable "emacs-lisp";
        symex = ide.symex;
        mode = [ ''("\\.Cask\\'" . emacs-lisp-mode)'' ];
        hook = lib.mkIf ide.flymake.enable [
          "(emacs-lisp-mode . flymake-mode)"
        ];
        gfhookf = lib.mkIf ide.symex [ "('emacs-lisp-mode (treesit! 'elisp))" ];
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
        hook = [ "(emacs-lisp-mode . highlight-quoted-mode)" ];
      };

      eldoc-box = lib.mkIf ide.hoverDoc {
        enable = true;
        hook = [ "(emacs-lisp-mode . eldoc-box-hover-at-point-mode)" ];
      };

      breadcrumb = lib.mkIf ide.breadcrumb {
        enable = true;
        hook = [ "(emacs-lisp-mode . breadcrumb-local-mode)" ];
      };
    };
  };
}
