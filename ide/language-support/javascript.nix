{ pkgs, config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.javascript.enable =
    lib.mkEnableOption "enables javascript support";

  config = lib.mkIf ide.languages.javascript.enable {
    programs.emacs.init.usePackage.js-ts-mode = {
      enable = true;
      extraPackages = if ide.lsp-bridge.enable || ide.lspce.enable
      || ide.lsp.enable || ide.eglot.enable then
        with pkgs; [ typescript-language-server ]
      else
        [ ];
      mode = [ ''"\\.js\\'"'' ];
      eglot = ide.eglot.enable;
      symex = ide.symex;
      lsp = ide.lsp.enable;
      lspce = ide.lspce.enable;
      config = lib.mkIf ide.lspce.enable ''
        (with-eval-after-load 'lspce (add-to-list 'lspce-server-programs '("js" "typescript-language-server" "--stdio")))
      '';
    };
  };
}
