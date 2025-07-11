{ pkgs, lib, config, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.haskell.enable = lib.mkEnableOption "enables haskell support";
  config = lib.mkIf ide.languages.haskell.enable {
    programs.emacs.init.usePackage.haskell-ts-mode = {
      enable = true;
      mode = [''"\\.hs\\'"''];
      extraPackages = if ide.lsp.enable || ide.eglot.enable then [pkgs.haskell-language-server] else [];
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      # symex = ide.symex;
    };
  };
}
