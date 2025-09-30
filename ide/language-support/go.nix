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
    ide.treesitter.wantTreesitter = true;
    usePackage = {
      go-ts-mode = {
        enable = true;
        mode = [ ''"\\.go\\'"'' ];
        symex = ide.symex;
        lsp = ide.lsp.enable;
        eglot = ide.eglot.enable;
        extraPackages =
          if ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable then
            [
              pkgs.gopls
              pkgs.go
            ]
          else
            [ ];
        lspce = lib.mkIf ide.lspce.enable '''("go" "go-dot-work" "go-dot-mod" "go-mod") "gopls"'';
      };

      ob-go = lib.mkIf ide.languages.org.enable {
        enable = true;
        babel = lib.mkIf ide.org.enable "go";
      };
    };
  };
}
