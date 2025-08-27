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
        extraPackages = [ pkgs.akkuPackages.scheme-langserver ];
        babel = lib.mkIf ide.languages.org.enable "scheme";
        symex = ide.symex;
        eglot = lib.mkIf ide.eglot.enable '''(scheme-mode . ("scheme-langserver"))'';
        lspce = ide.lspce.enable;
        init = ''(setq auto-mode-alist (delete '("\\.rkt\\'" . scheme-mode) auto-mode-alist))'';
        config = ''
          (setq auto-mode-alist (delete '("\\.rkt\\'" . scheme-mode) auto-mode-alist))
          ${
            if ide.lspce.enable then
              ''(with-eval-after-load 'lspce (add-to-list 'lspce-server-programs '("scheme" "scheme-langserver" "")))''
            else
              ""
          }
        '';
      };
    };
  };
}
