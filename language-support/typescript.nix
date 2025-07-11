{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.typescript.enable = lib.mkEnableOption "enables typescript support";

  config = lib.mkIf ide.languages.typescript.enable {
    programs.emacs.init.usePackage.typescript-ts-mode = {
      enable = true;
      extraPackages = if ide.lsp.enable || ide.eglot.enable then with pkgs; [typescript-language-server] else [];
      mode = [''"\\.ts\\'"''];
      eglot = ide.eglot.enable;
      symex = ide.symex;
      lsp = ide.lsp.enable;
    };
  };
}
