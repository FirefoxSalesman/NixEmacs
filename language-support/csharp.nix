{ pkgs, lib, config, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.csharp.enable = lib.mkEnableOption
    "Enables csharp support. You will be forced to use csharp-ls, because I can't find omnisharp in nixpkgs";

  config = lib.mkIf ide.languages.csharp.enable {
    programs.emacs.init.usePackage = {
      csharp-ts-mode = {
        enable = true;
        mode = [ ''"\\.cs\\'"'' ];
        extraPackages = if ide.lsp-bridge.enable || ide.lspce.enable
        || ide.lsp.enable || ide.eglot.enable then
          [ pkgs.csharp-ls ]
        else
          [ ];
        eglot = ide.eglot.enable;
        lsp = ide.lsp.enable;
        lspce = ide.lspce.enable;
        lsp-bridge = ide.lsp-bridge.enable;
        symex = ide.symex;
        config = lib.mkIf ide.lspce.enable ''
          (with-eval-after-load 'lspce (add-to-list mode 'lspce-server-programs (list "csharp" "csharp-lsp" "")))
        '';
      };

      lsp-bridge.custom.lsp-bridge-csharp-lsp-server =
        lib.mkIf ide.lsp-bridge.enable ''"csharp-ls"'';
    };
  };
}
