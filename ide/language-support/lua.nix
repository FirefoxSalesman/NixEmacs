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

  config = lib.mkIf ide.languages.lua.enable {
    programs.emacs.init.usePackage.lua-ts-mode = {
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
      lspce = ide.lspce.enable;
      config = lib.mkIf ide.lspce.enable ''(nix-emacs-lspce-add-server-program '("lua") "lua-language-server")'';
    };
  };
}
