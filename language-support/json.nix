{ pkgs, config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.json.enable =
    lib.mkEnableOption "enables json support";

  config = lib.mkIf ide.languages.json.enable {
    programs.emacs.init.usePackage = {
      json-ts-mode = {
        enable = true;
        extraPackages = if ide.lsp-bridge.enable || ide.lspce.enable
        || ide.lsp.enable || ide.eglot.enable then
          with pkgs; [ vscode-langservers-extracted ]
        else
          [ ];
        mode = [ ''"\\.json\\'"'' ];
        lsp = ide.lsp.enable;
        lspce = ide.lspce.enable;
        eglot = ide.eglot.enable;
        symex = ide.symex;
        config = lib.mkIf ide.lspce.enable ''
          (with-eval-after-load 'lspce (add-to-list 'lspce-server-programs '("json" "vscode-json-language-server" "--stdio")))
        '';
      };

      json5-ts-mode = {
        enable = true;
        extraPackages = [ pkgs.vscode-langservers-extracted ];
        mode = [ ''"\\.json5\\'"'' ];
        eglot = lib.mkIf ide.eglot.enable ''("vscode-json-language-server" "--stdio")'';
        symex = ide.symex;
        lspce = ide.lspce.enable;
        config = lib.mkIf ide.lspce.enable ''
          (with-eval-after-load 'lspce (add-to-list 'lspce-server-programs '("json5" "vscode-json-language-server" "--stdio")))
        '';
      };
    };
  };
}
