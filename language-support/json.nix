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
        lsp-bridge = ide.lsp-bridge.enable;
        eglot = ide.eglot.enable;
        symex = ide.symex;
        config = lib.mkIf ide.lspce.enable ''
          (with-eval-after-load 'lspce (add-to-list 'lspce-server-programs '("json" "vscode-json-language-server" "--stdio")))
        '';
      };
    };
  };
}
