{
  pkgs,
  lib,
  config,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.scheme = {
    enable = lib.mkEnableOption "Enables scheme support, via scheme-langserver";
  };

  config = lib.mkIf ide.languages.scheme.enable {
    programs.emacs.init.usePackage = {
      scheme = {
        enable = true;
        extraPackages = lib.mkIf (ide.eglot.enable || ide.lsp.enable || ide.lspce.enable) [ pkgs.akkuPackages.scheme-langserver ];
        babel = lib.mkIf ide.languages.org.enable "scheme";
        symex = ide.symex;
        eglot = lib.mkIf ide.eglot.enable '''(scheme-mode . ("scheme-langserver"))'';
        lspce = lib.mkIf ide.lspce.enable ''"scheme" "scheme-langserver"'';
        lsp = lib.mkIf ide.lsp.enable;
        init = ''(setq auto-mode-alist (delete '("\\.rkt\\'" . scheme-mode) auto-mode-alist))'';
        config = ''
          (setq auto-mode-alist (delete '("\\.rkt\\'" . scheme-mode) auto-mode-alist))
          ${if ide.lsp.enable then ''
          (with-eval-after-load 'lsp-mode
                                (add-to-list 'lsp-language-id-configuration '(scheme-mode . "scheme"))
                                (lsp-register-client
                                  (make-lsp-client :new-connection (lsp-stdio-connection "scheme-langserver")
                                                                                     :major-modes '(scheme-mode)
                                                   :activation-fn (lsp-activate-on "scheme")
                                                   :server-id 'scheme-langserver)))
        '' else ""}
        '';
      };
    };
  };
}
