{ pkgs, config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.java.enable =
    lib.mkEnableOption "enables java support";

  config = lib.mkIf ide.languages.java.enable {
    programs.emacs.init.usePackage = {
      java-ts-mode = {
        enable = true;
        extraPackages =
          if ide.lspce.enable || ide.lsp-bridge.enable || ide.eglot.enable then with pkgs; [ jdt-language-server ] else [ ];
        mode = [ ''"\\.java\\'"'' ];
        lsp = ide.lsp.enable;
        lspce = ide.lspce.enable;
        lsp-bridge = ide.lsp-bridge.enable;
        eglot = ide.eglot.enable;
        symex = ide.symex;
        config lib.mkIf ide.lspce.enable ''
          (with-eval-after-load 'lspce (add-to-list 'lspce-server-programs '("java" "jdtls" "")))
        '';
      };

      lsp-java = lib.mkIf ide.lsp.enable {
        enable = true;
        after = [ "lsp-mode" ];
        custom.lsp-java-prefer-native-command = "t";
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
    };
  };
}
