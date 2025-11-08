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
  options.programs.emacs.init.ide.languages.lua.enable = lib.mkEnableOption "enables lua support";

  config.programs.emacs.init = lib.mkIf ide.languages.lua.enable {
    ide = {
      treesitter.wantTreesitter = true;
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "lua-ts-mode" ];
    };
    usePackage.lua-ts-mode = {
      enable = true;
      babel = lib.mkIf ide.languages.org.enable "lua";
      extraPackages =
        if ide.eglot.enable || ide.lsp.enable || ide.lspce.enable || ide.lsp-bridge.enable then
          [ pkgs.lua-language-server ]
        else
          [ ];
      mode = [ ''"\\.lua\\'"'' ];
      eglot = lib.mkIf ide.eglot.enable ''"lua-language-server"'';
      lsp = ide.lsp.enable;
      lspce = lib.mkIf ide.lspce.enable ''"lua" "lua-language-server"'';
      symex = ide.symex.enable;
    };
  };
}
