{
  pkgs,
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.javascript.enable =
    lib.mkEnableOption "enables javascript support";

  config.programs.emacs.init = lib.mkIf ide.languages.javascript.enable {
    ide.treesitter.wantTreesitter = true;
    usePackage.js-ts-mode = {
      enable = true;
      babel = lib.mkIf ide.languages.org.enable "js";
      extraPackages =
        if ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable then
          with pkgs; [ typescript-language-server ]
        else
          [ ];
      mode = [ ''"\\.js\\'"'' ];
      eglot = ide.eglot.enable;
      symex = ide.symex;
      lsp = ide.lsp.enable;
      lspce = lib.mkIf ide.lspce.enable ''"js" "typescript-language-server" "--stdio"'';
    };
  };
}
