{ pkgs, lib, config, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.lua.enable =
    lib.mkEnableOption "enables lua support";

  config = lib.mkIf ide.languages.lua.enable {
    programs.emacs.init.usePackage.lua-ts-mode = {
      enable = true;
      extraPackages = if ide.eglot.enable || ide.lsp.enable || ide.lspce.enable
      || ide.lsp-bridge.enable then
        [ pkgs.lua-language-server ]
      else
        [ ];
      mode = [ ''"\\.lua\\'"'' ];
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      lspce = ide.lspce.enable;
      lsp-bridge = ide.lsp-bridge.enable;
      config = lib.mkIf (ide.eglot.enable || ide.lspce.enable) ''
        ${if ide.eglot.enable then ''
          (with-eval-after-load 'eglot
                                (add-to-list 'eglot-server-programs '((lua-ts-mode) . ("lua-language-server"))))'' else ''
            (with-eval-after-load 'lspce (add-to-list 'lspce-server-programs '("lua" "lua-language-server" "")))
          ''}
      '';
    };
  };
}
