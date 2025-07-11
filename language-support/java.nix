{ pkgs, config, lib, ... } :

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.java.enable = lib.mkEnableOption "enables java support";

  config = lib.mkIf ide.languages.java.enable {
    programs.emacs.init.usePackage.java-ts-mode = {
      enable = true;
      extraPackages = if ide.lsp.enable || ide.eglot.enable then with pkgs; [jdt-language-server] else [];
      mode = [''"\\.java\\'"''];
      lsp = ide.lsp.enable;
      eglot = ide.eglot.enable;
      symex = ide.symex;
    };
  };
}
