{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.json.enable = lib.mkEnableOption "enables json support";

  config = lib.mkIf ide.languages.json.enable {
    programs.emacs.init.usePackage = {
      json-ts-mode = {
        enable = true;
        extraPackages = if ide.lsp.enable || ide.eglot.enable then with pkgs; [vscode-langservers-extracted] else [];
        mode = [''"\\.json\\'"''];
        lsp = ide.lsp.enable;
        eglot = ide.eglot.enable;
        symex = ide.symex;
      };
    };
  };
}
