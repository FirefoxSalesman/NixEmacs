{ pkgs, config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.purescript.enable =
    lib.mkEnableOption
    "Enables purescript support. Formatting is poorly tested at best";

  config = lib.mkIf ide.languages.purescript.enable {
    programs.emacs.init.usePackage.purescript-mode = {
      enable = true;
      # borrowed from doom
      hook = [ "(purescript-mode . purescript-indentation-mode)" ];
      extraPackages =
        if ide.eglot.enable || ide.lspce.enable || ide.lsp.enable then
          [ pkgs.nodePackages.purescript-language-server ]
        else
          [ ];
      eglot = lib.mkIf ide.eglot.enable ''
        ("purescript-language-server" "--stdio" :initializationOptions (:purescript (:formatter "purs-tidy")))'';
      lsp = ide.lsp.enable;
      lspce = ide.lspce.enable;
      symex = ide.symex;
      config = lib.mkIf ide.lspce.enable ''(nix-emacs-lspce-add-server-program "purescript" "purescript-language-server" "--stdio")'';
    };
  };
}
