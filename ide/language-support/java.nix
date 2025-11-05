{
  pkgs,
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
  completions = config.programs.emacs.init.completions;
in
{
  options.programs.emacs.init.ide.languages.java = {
    enable = lib.mkEnableOption "enables java support";
    moreEglot = lib.mkEnableOption "Installs eglot-java. This means you can use more of jdtls's features, but emacs will have to install it for you (rather than nix)";
  };

  config = lib.mkIf ide.languages.java.enable {
    programs.emacs.init = {
      ide.treesitter.wantTreesitter = true;
      completions.tempel.templates.java-ts-mode = lib.mkIf completions.tempel.enable {
        doc = ''"/**" n> " * " q n " */"'';
        "if" = ''"if (" p ") {" n> q n "}"'';
        class = ''"public class " (p (file-name-base (or (buffer-file-name) (buffer-name)))) " {" n> r> n "}"'';
        method = ''p " " p " " p "(" p ") {" n> q n "}"'';
        while = ''"while (" p ") {" n> q n "}"'';
      };
      usePackage = {
        java-ts-mode = {
          enable = true;
          babel = lib.mkIf ide.languages.org.enable "java";
          bindLocal.java-ts-mode-map."RET" = lib.mkDefault ''
            (lambda ()
                 (interactive)
                 (nix-emacs/starred-newline "block_comment"))'';
          generalTwoConfig.":n".java-ts-mode-map = lib.mkIf config.programs.emacs.init.keybinds.evil.enable {
            "o" = lib.mkDefault lib.mkDefault ''
                '(lambda ()
              	  (interactive)
                  (nix-emacs/starred-evil-open 'evil-open-below "block_comment"))'';
            "O" = lib.mkDefault lib.mkDefault ''
                '(lambda ()
              	  (interactive)
                  (nix-emacs/starred-evil-open 'evil-open-above "block_comment"))'';
          };
          extraPackages =
            if
              ide.lsp.enable
              || ide.lspce.enable
              || ide.lsp-bridge.enable
              || (ide.eglot.enable && !ide.languages.java.moreEglot)
            then
              with pkgs; [ jdt-language-server ]
            else
              [ ];
          mode = [ ''"\\.java\\'"'' ];
          lsp = ide.lsp.enable;
          eglot = ide.eglot.enable;
          symex = ide.symex;
          lspce = lib.mkIf ide.lspce.enable ''"java" "jdtls"'';
        };

        lsp-java = lib.mkIf ide.lsp.enable {
          enable = true;
          after = [ "lsp-mode" ];
          setopt.lsp-java-prefer-native-command = lib.mkDefault true;
          config = ''
                ;; https://github.com/emacs-lsp/lsp-java/issues/487
                (defun java-server-subdir-for-jar (orig &rest args)
                  "Add nix subdir to `lsp-java-server-install-dir' so that the lsp test
            succeeds."
                  (let ((lsp-java-server-install-dir
                          ;;(expand-file-name "./share/java/jdtls/" lsp-java-server-install-dir)))
                          (expand-file-name "./share/java/jdtls/" "${pkgs.jdt-language-server}")))
                    (apply orig args)))
                (advice-add 'lsp-java--locate-server-jar :around #'java-server-subdir-for-jar)

                ;; https://github.com/emacs-lsp/lsp-java/issues/421
                (defun lsp-java--ls-command () "jdtls")
          '';
        };

        eglot-java = lib.mkIf ide.languages.java.moreEglot {
          enable = true;
          after = [ "eglot" ];
          config = "(eglot-java-mode)";
        };
      };
    };
  };
}
