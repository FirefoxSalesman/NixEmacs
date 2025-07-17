{ pkgs, lib, config, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.sql.enable =
    lib.mkEnableOption "enables sql support";

  config = lib.mkIf ide.languages.sql.enable {
    programs.emacs.init.usePackage.sql = {
      enable = true;
      extraPackages =
        if ide.eglot.enable || ide.lspce.enable || ide.lsp.enable then
          [ pkgs.sqls ]
        else
          [ ];
      mode = [ ''"\\.sql\\'"'' ];
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      lspce = ide.lspce.enable;
      symex = ide.symex;
      config = lib.mkIf (ide.eglot.enable || ide.lspce.enable) ''
        ${if ide.eglot.enable then ''
          (with-eval-after-load 'eglot
                    (add-to-list 'eglot-server-programs '((sql-mode) . ("sqls"))))'' else
          ''
            (with-eval-after-load 'lspce (add-to-list 'lspce-server-programs '("sql" "sqls" "")))''}
      '';
    };
  };
}
