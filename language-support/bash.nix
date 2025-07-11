{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.bash.enable = lib.mkEnableOption "enables bash support";
  
  config = lib.mkIf ide.languages.bash.enable {
    programs.emacs.init.usePackage.bash-ts-mode = {
      enable = true;
      extraPackages = if ide.lsp.enable || ide.eglot.enable then with pkgs; [nodePackages.bash-language-server] else [];
      mode = [''"\\.sh\\'"''];
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
    };
  };
}
