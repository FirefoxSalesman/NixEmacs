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
  options.programs.emacs.init.ide.languages.javascript.enable =
    lib.mkEnableOption "enables javascript support";

  config.programs.emacs.init = lib.mkIf completions.tempel.enable {
    completions.tempel.templates.js-ts-mode = lib.mkIf ide.languages.javascript.enable {
      clg = ''"console.log(" p ");"'';
      doc = ''"/**" n> " * " q n " */"'';
      anfn = ''"(" p ") => {" n> q n "};"'';
      qs = ''"document.querySelector(\"" q "\");"'';
      "if" = ''"if (" p ") {" n> q n "}"'';
    };
    ide = {
      treesitter.wantTreesitter = true;
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "js-ts-mode" ];
    };
    usePackage.js-ts-mode = {
      enable = true;
      babel = lib.mkIf ide.languages.org.enable "js";
      extraPackages =
        (
          if ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable then
            with pkgs; [ typescript-language-server ]
          else
            [ ]
        )
        ++ (if (ide.dap.enable || ide.dape.enable) then [ pkgs.vscode-js-debug ] else [ ]);
      mode = [ ''"\\.js\\'"'' ];
      eglot = ide.eglot.enable;
      symex = ide.symex;
      lsp = ide.lsp.enable;
      lspce = lib.mkIf ide.lspce.enable ''"js" "typescript-language-server" "--stdio"'';
      config = lib.mkIf ide.dap.enable "(require 'dap-node)";
    };
  };
}
