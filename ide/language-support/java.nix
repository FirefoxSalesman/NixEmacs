{
  pkgs,
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.java = {
    enable = lib.mkEnableOption "enables java support";
    moreEglot = lib.mkEnableOption "Installs eglot-java. This means you can use more of jdtls's features, but emacs will have to install it for you (rather than nix)";
  };

  config = lib.mkIf ide.languages.java.enable {
    programs.emacs.init.usePackage = {
      java-ts-mode = {
        enable = true;
        babel = lib.mkIf ide.languages.org.enable "java";
        extraPackages =
          if ide.lspce.enable || ide.lsp-bridge.enable || (ide.eglot.enable && !ide.languages.java.moreEglot) then
            with pkgs; [ jdt-language-server ]
          else
            [ ];
        mode = [ ''"\\.java\\'"'' ];
        lsp = ide.lsp.enable;
        lspce = ide.lspce.enable;
        eglot = ide.eglot.enable;
        symex = ide.symex;
        config = lib.mkIf ide.lspce.enable ''(nix-emacs-lspce-add-server-program "java" "jdtls")'';
      };

      lsp-java = lib.mkIf ide.lsp.enable {
        enable = true;
        after = [ "lsp-mode" ];
        custom.lsp-java-prefer-native-command = true;
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
        after = ["eglot"];
        config = "(eglot-java-mode)";
      };
    };
  };
}
