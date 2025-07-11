{ pkgs, lib, config, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.sql.enable = lib.mkEnableOption "enables sql support";

  config = lib.mkIf ide.languages.sql.enable {
    programs.emacs.init.usePackage.sql = {
      enable = true;
      extraPackages = if ide.eglot.enable || ide.lsp.enable then [pkgs.sqls] else [];
      mode = [''"\\.sql\\'"''];
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      symex = ide.symex;
      config = ''
        (with-eval-after-load 'eglot
          (add-to-list 'eglot-server-programs '((sql-mode) . ("sqls"))))
      '';
    };
  };
}
