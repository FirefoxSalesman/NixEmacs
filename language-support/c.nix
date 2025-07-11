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
        extraPackages = if ide.lsp.enable || ide.eglot.enable then
          if ide.languages.c.preferClangd then [pkgs.clang-tools] else [pkgs.ccls]
                        else [];
        mode = [''"\\.c\\'"''];
        eglot = ide.eglot.enable;
        lsp = ide.lsp.enable;
        symex = ide.symex;
      };

      ccls.enable = ide.lsp.enable;
    };
  } ;
}
