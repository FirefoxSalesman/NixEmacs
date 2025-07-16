{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.purescript.enable = lib.mkEnableOption "Enables purescript support. Formatting is poorly tested at best";

  config = lib.mkIf ide.languages.purescript.enable {
    programs.emacs.init.usePackage.purescript-mode = {
      enable = true;
      # borrowed from doom
      hook = ["(purescript-mode . purescript-indentation-mode)"];
      extraPackages = if ide.eglot.enable || ide.lsp.enable then [pkgs.nodePackages.purescript-language-server] else [];
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      symex = ide.symex;
      config = ''
        (with-eval-after-load 'eglot
          (add-to-list 'eglot-server-programs '((purescript-mode) . ("purescript-language-server" "--stdio"
                                                                     :initializationOptions (:purescript (:formatter "purs-tidy"))))))
      '';
    };
  };
}
