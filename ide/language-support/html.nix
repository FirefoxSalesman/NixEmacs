{
  pkgs,
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.html = {
    enable = lib.mkEnableOption "enables html support";
    emmet = lib.mkEnableOption "enables emmet for html";
  };

  config = lib.mkIf ide.languages.html.enable {
    programs.emacs.init.usePackage = {
      ide = {
        treesitter.wantTreesitter = true;
        treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "html-ts-mode" ];
      };
      html-ts-mode = {
        enable = true;
        extraPackages =
          if ide.lsp-bridge.enable || ide.lsp.enable || ide.eglot.enable then
            with pkgs; [ vscode-langservers-extracted ]
          else
            [ ];
        # many thanks to doom
        mode = [ ''"\\.[px]?html?\\'"'' ];
        lspce = lib.mkIf ide.lspce.enable ''"html" "vscode-html-language-server" "--stdio"'';
        eglot = lib.mkIf ide.eglot.enable ''("vscode-html-language-server" "--stdio")'';
        symex = ide.symex;
        lsp = ide.lsp.enable;
      };

      emmet-mode = {
        enable = ide.html.emmet;
        hook = [ "(html-ts-mode . emmet-mode)" ];
        setopt.emmet-move-cursor-between-quotes = lib.mkDefault true;
      };
    };
  };
}
