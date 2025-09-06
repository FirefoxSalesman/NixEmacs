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
  options.programs.emacs.init.ide.languages.c = {
    enable = lib.mkEnableOption "enables c/c++ support";
    preferClangd = lib.mkEnableOption "uses clang instead of ccls";
  };

  config = lib.mkIf ide.languages.c.enable {
    programs.emacs.init.usePackage = {
      c-ts-mode = {
        enable = true;
        babel = lib.mkIf ide.languages.org.enable "C";
        extraPackages = lib.mkIf (
          ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable
        ) (if ide.languages.c.preferClangd then [ pkgs.clang-tools ] else [ pkgs.ccls ]);
        mode = [ ''"\\.c\\'"'' ];
        eglot = ide.eglot.enable;
        lsp = ide.lsp.enable;
        symex = ide.symex;
        lspce = lib.mkIf ide.lspce.enable ''"C" "${if ide.languages.c.preferClangd then "clangd" else "ccls"}"'';
      };

      ccls = lib.mkIf (ide.lsp.enable && !ide.languages.c.preferClangd) {
        enable = true;
        after = [ "lsp-mode" ];
      };

      lsp-bridge.custom.lsp-bridge-c-lsp-server = lib.mkIf ide.lsp-bridge.enable (
        if !ide.languages.c.preferClangd then ''"ccls"'' else ''"clangd"''
      );
    };
  };
}
