{ pkgs, lib, config, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.haskell.enable =
    lib.mkEnableOption "enables haskell support";
  config = lib.mkIf ide.languages.haskell.enable {
    programs.emacs.init.usePackage.haskell-ts-mode = {
      enable = true;
      mode = [ ''"\\.hs\\'"'' ];
      extraPackages = if ide.lsp-bridge.enable || ide.lspce.enable
      || ide.lsp.enable || ide.eglot.enable then
        [ pkgs.haskell-language-server ]
      else
        [ ];
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      lspce = ide.lspce.enable;
      lsp-bridge = ide.lsp-bridge.enable;
      # symex = ide.symex;
      config = lib.mkIf ide.lspce.enable ''
        (with-eval-after-load 'lspce (add-to-list 'lspce-server-programs (list "haskell" "haskell-language-server-wrapper" "--lsp")))
      '';
    };
  };
}
