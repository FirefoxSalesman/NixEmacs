{
  pkgs,
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
  completions = config.programs.emacs.init.completions;
in
{
  options.programs.emacs.init.ide.languages.typescript.enable =
    lib.mkEnableOption "enables typescript support";

  config.programs.emacs.init = lib.mkIf ide.languages.typescript.enable {
    completions.tempel.templates.typescript-ts-mode = lib.mkIf completions.tempel.enable {
      clg = ''"console.log(" p ");"'';
      doc = ''"/**" n> " * " q n " */"'';
      anfn = ''"(" p ") => {" n> q n "};"'';
      qs = ''"document.querySelector(\"" q "\");"'';
      "if" = ''"if (" p ") {" n> q n "}"'';
    };
    ide = {
      treesitter.wantTreesitter = true;
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "typescript-ts-mode" ];
    };
    usePackage.typescript-ts-mode = {
      enable = true;
      babel = lib.mkIf ide.languages.org.enable "typescript";
      extraPackages =
        (
          if ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable then
            with pkgs; [ typescript-language-server ]
          else
            [ ]
        )
        ++ (if (ide.dap.enable || ide.dape.enable) then [ pkgs.vscode-js-debug ] else [ ]);
      mode = [ ''"\\.ts\\'"'' ];
      eglot = ide.eglot.enable;
      symex = ide.symex;
      lsp = ide.lsp.enable;
      lspce = lib.mkIf ide.lspce.enable '''("tsx" "typescript") "typescript-language-server" "--stdio"'';
      config = lib.mkIf ide.dap.enable "(require 'dap-node)";
    };
  };
}
