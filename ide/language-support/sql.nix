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
  options.programs.emacs.init.ide.languages.sql.enable = lib.mkEnableOption "enables sql support";

  config = lib.mkIf ide.languages.sql.enable {
    programs.emacs.init = {
      tools.apheleia.modeFormatters.sql-mode = lib.mkIf (
        config.programs.emacs.init.tools.apheleia.enable && (ide.eglot.enable || ide.lsp.enable)
      ) (lib.mkDefault (if ide.eglot.enable then "eglot" else "lsp"));
      usePackage.sql = {
        enable = true;
        babel = lib.mkIf ide.languages.org.enable "sql";
        extraPackages =
          if ide.eglot.enable || ide.lspce.enable || ide.lsp.enable then [ pkgs.sqls ] else [ ];
        mode = [ ''"\\.sql\\'"'' ];
        eglot = lib.mkIf ide.eglot.enable ''"sqls"'';
        lsp = ide.lsp.enable;
        lspce = lib.mkIf ide.lspce.enable ''"sql" "sqls"'';
      };
    };
  };
}
