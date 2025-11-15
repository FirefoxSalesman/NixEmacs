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
  options.programs.emacs.init.ide.languages.go.enable = lib.mkEnableOption "enables go support";

  config.programs.emacs.init = lib.mkIf ide.languages.go.enable {
    ide = {
      treesitter.wantTreesitter = true;
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "go-ts-mode" ];
    };
    usePackage = {
      go-ts-mode = {
        enable = true;
        mode = [ ''"\\.go\\'"'' ];
        symex = ide.symex;
        lsp = ide.lsp.enable;
        eglot = ide.eglot.enable;
        extraPackages =
          (
            if ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable then
              [
                pkgs.gopls
                pkgs.go
              ]
            else
              [ ]
          )
          ++ (if (ide.dap.enable || ide.dape.enable) then [ pkgs.delve ] else [ ]);
        lspce = lib.mkIf ide.lspce.enable '''("go" "go-dot-work" "go-dot-mod" "go-mod") "gopls"'';
        config = lib.mkIf ide.dap.enable "(require 'dap-dlv-go)";
      };

      ob-go = lib.mkIf ide.languages.org.enable {
        enable = true;
        babel = lib.mkIf ide.org.enable "go";
      };
    };
  };
}
