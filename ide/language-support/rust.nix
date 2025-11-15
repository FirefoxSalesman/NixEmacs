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
  options.programs.emacs.init.ide.languages.rust = {
    enable = lib.mkEnableOption "enables rust support";
    preferGdb = lib.mkEnableOption "uses gdb instead of lldb for debugging";
  };

  config.programs.emacs.init = lib.mkIf ide.languages.rust.enable {
    ide = {
      treesitter.wantTreesitter = true;
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "rustic-mode" ];
    };
    usePackage = {
      rust-ts-mode = {
        enable = true;
        defer = true;
        extraPackages =
          (
            if ide.lsp-bridge.enable || ide.lsp.enable || ide.lspce.enable || ide.eglot.enable then
              [ pkgs.rust-analyzer ]
            else
              [ ]
          )
          ++ (
            if (ide.dap.enable || ide.dape.enable) then
              (if ide.languages.rust.preferGdb then [ pkgs.gdb ] else [ pkgs.lldb ])
            else
              [ ]
          );
        lsp = ide.lsp.enable;
        lspce = lib.mkIf ide.lspce.enable ''"rustic" "rust-analyzer"'';
        eglot = lib.mkIf ide.eglot.enable ''("rust-analyzer" :initializationOptions (:check (:command "clippy")))'';
        symex = ide.symex;
        config = lib.mkIf ide.dap.enable (
          if ide.languages.rust.preferGdb then "(require 'dap-gdb)" else "(require 'dap-lldb)"
        );
      };

      rustic = {
        enable = true;
        mode = [ ''("\\.rs$" . rustic-mode)'' ];
        setopt = {
          rust-mode-treesitter-derive = lib.mkDefault true;
          rustic-lsp-client = lib.mkDefault (
            if ide.eglot.enable then
              "'eglot"
            else if ide.lsp.enable then
              "'lsp-mode"
            else
              false
          );
        };
      };
    };
  };
}
