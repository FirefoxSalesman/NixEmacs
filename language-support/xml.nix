{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.xml.enable = lib.mkEnableOption "Enables xml support.";

  config = lib.mkIf ide.languages.xml.enable {
    programs.emacs.init.usePackage.nxml = {
      enable = true;
      mode = [''("\\.xml\\'" . nxml-mode)''];
      extraPackages = if ide.eglot.enable || ide.lsp-bridge.enable then [pkgs.lemminx] else [];
      lsp-bridge = ide.lsp-bridge.enable;
      eglot = ide.eglot.enable;
      symex = ide.symex;
      init = ''
          (with-eval-after-load 'eglot
            (add-to-list 'eglot-server-programs '((nxml-mode) . ("lemminx"))))
        '';
    };
  };
}
