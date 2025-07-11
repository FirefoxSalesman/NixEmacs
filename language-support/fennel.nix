{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.fennel.enable = lib.mkEnableOption "enables fennel support";

  config = lib.mkIf ide.languages.fennel.enable {
    programs.emacs.init.usePackage.fennel-mode = {
      enable = true;
      extraPackages = if ide.eglot.enable || ide.lsp.enable then [pkgs.fennel-ls] else [];
      mode = [''"\\.fnl\\'"''];
      symex = ide.symex;
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      config = ''
        (with-eval-after-load 'eglot
          (add-to-list 'eglot-server-programs '(fennel-mode . ("fennel-ls"))))
      '';
    };
  };
}
