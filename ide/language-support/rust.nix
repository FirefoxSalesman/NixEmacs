{ pkgs, lib, config, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.rust.enable =
    lib.mkEnableOption "enables rust support";

  config = lib.mkIf ide.languages.rust.enable {
    programs.emacs.init.usePackage = {
      rust-ts-mode = {
        enable = true;
        defer = true;
        extraPackages = if ide.lsp-bridge.enable || ide.lsp.enable
        || ide.lspce.enable || ide.eglot.enable then
          [ pkgs.rust-analyzer ]
        else
          [ ];
        lsp = ide.lsp.enable;
        lspce = ide.lspce.enable;
        eglot = lib.mkIf ide.eglot.enable ''
          ("rust-analyzer" :initializationOptions (:check (:command "clippy")))'';
        symex = ide.symex;
      };

      rustic = {
        enable = true;
        mode = [ ''("\\.rs$" . rustic-mode)'' ];
        custom = {
          rust-mode-treesitter-derive = lib.mkDefault true;
          rustic-lsp-client = lib.mkDefault (if ide.eglot.enable then
            "'eglot"
          else if ide.lsp.enable then
            "'lsp-mode"
          else
            false);
        };
        config = lib.mkIf ide.lspce.enable ''(nix-emacs-lspce-add-server-program '("rustic") "rust-analyzer")'';
      };
    };
  };
}
