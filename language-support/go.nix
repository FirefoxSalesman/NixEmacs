{ pkgs, lib, config, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.go.enable =
    lib.mkEnableOption "enables go support";

  config = lib.mkIf ide.languages.go.enable {
    programs.emacs.init.usePackage.go-ts-mode = {
      enable = true;
      mode = [ ''"\\.go\\'"'' ];
      symex = ide.symex;
      lsp = ide.lsp.enable;
      lspce = ide.lspce.enable;
      lsp-bridge = ide.lsp-bridge.enable;
      eglot = ide.eglot.enable;
      extraPackages = if ide.lsp-bridge.enable || ide.lspce.enable
      || ide.lsp.enable || ide.eglot.enable then [
        pkgs.gopls
        pkgs.go
      ] else
        [ ];
      config = lib.mkIf ide.lspce.enable ''
        (with-eval-after-load 'lspce
                              (dolist (mode '("go" "go-dot-work" "go-dot-mod" "go-mod")))
                                      (add-to-list 'lspce-server-programs (list "gopls" "")))
      '';
    };
  };
}
