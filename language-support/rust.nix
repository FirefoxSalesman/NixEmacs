{ pkgs, lib, config, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.rust.enable = lib.mkEnableOption "enables rust support";

  config = lib.mkIf ide.languages.rust.enable {
    programs.emacs.init.usePackage = {
      rust-ts-mode = {
        enable = true;
        defer = true;
        extraPackages = if ide.lsp.enable || ide.eglot.enable then [pkgs.rust-analyzer] else [];
        lsp = ide.lsp.enable;
        eglot = ide.eglot.enable;
        symex = ide.symex;
      };

      rustic = {
        enable = true;
        mode = [''("\\.rs$" . rustic-mode)''];
        custom = {
          rust-mode-treesitter-derive = lib.mkDefault "t";
          rustic-lsp-client = lib.mkDefault (if ide.eglot then "'eglot" else
            if ide.lsp then "'lsp-mode" else
              "nil");
        };
        config = ''
          (with-eval-after-load 'eglot
            (add-to-list 'eglot-server-programs '((rust-ts-mode rust-mode) . ("rust-analyzer" :initializationOptions (:check (:command "clippy"))))))
        '';
      };
    };
  };
}
