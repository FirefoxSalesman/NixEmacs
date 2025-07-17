{ pkgs, config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.web = {
    enable = lib.mkEnableOption "enables html support";
    emmet = lib.mkEnableOption "enables emmet for html";
  };

  config = lib.mkIf ide.languages.web.enable {
    programs.emacs.init.usePackage = {
      html-ts-mode = {
        enable = true;
        extraPackages =
          if ide.lsp-bridge.enable || ide.lsp.enable || ide.eglot.enable then
            with pkgs; [ vscode-langservers-extracted ]
          else
            [ ];
        # many thanks to doom
        mode = [ ''"\\.[px]?html?\\'"'' ];
        config = lib.mkIf (ide.eglot.enable || ide.lspce.enable) ''
          ${if ide.eglot.enable then ''
            (with-eval-after-load 'eglot
              (add-to-list 'eglot-server-programs '((html-ts-mode) . ("vscode-html-language-server" "--stdio"))))
          '' else ''
            (add-to-list 'lspce-server-programs '("html" "vscode-html-language-server" "--stdio"))
          ''}
        '';
        eglot = ide.eglot.enable;
        symex = ide.symex;
        lsp = ide.lsp.enable;
        lspce = ide.lspce.enable;
        lsp-bridge = ide.lsp-bridge.enable;
      };

      emmet-mode = {
        enable = ide.html.emmet;
        hook = [ "(html-ts-mode . emmet-mode)" ];
        custom.emmet-move-cursor-between-quotes = lib.mkDefault "t";
      };
    };
  };
}
