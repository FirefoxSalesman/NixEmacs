{ pkgs, lib, config, ... }:

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
        extraPackages = if ide.lsp-bridge.enable || ide.lsp.enable || ide.eglot.enable then
          if ide.languages.c.preferClangd then [pkgs.clang-tools] else [pkgs.ccls]
                        else [];
        mode = [''"\\.c\\'"''];
        eglot = ide.eglot.enable;
        lsp = ide.lsp.enable;
        lsp-bridge = ide.lsp-bridge.enable;
        symex = ide.symex;
      };

      ccls = lib.mkIf (ide.lsp.enable && !ide.languages.c.preferClangd) {
        enable = true;
        after = ["lsp-mode"];
      };

      lsp-bridge.custom.lsp-bridge-c-lsp-server = lib.mkIf ide.lsp-bridge.enable (if !ide.languages.c.preferClangd then ''"ccls"'' else ''"clangd"'');
    };
  } ;
}
