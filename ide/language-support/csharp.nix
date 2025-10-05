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
  options.programs.emacs.init.ide.languages.csharp.enable =
    lib.mkEnableOption "Enables csharp support. You will be forced to use csharp-ls, because I can't find omnisharp in nixpkgs";

  config.programs.emacs.init = lib.mkIf ide.languages.csharp.enable {
    ide.treesitter.wantTreesitter = true;
    usePackage = {
      csharp-ts-mode = {
        enable = true;
        mode = [ ''"\\.cs\\'"'' ];
        extraPackages =
          if ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable then
            [ pkgs.csharp-ls ]
          else
            [ ];
        eglot = ide.eglot.enable;
        lsp = ide.lsp.enable;
        symex = ide.symex;
        lspce = lib.mkIf ide.lspce.enable ''"csharp" "csharp-lsp"'';
      };

      lsp-bridge.setopt.lsp-bridge-csharp-lsp-server = lib.mkIf ide.lsp-bridge.enable ''"csharp-ls"'';
    };
  };
}
