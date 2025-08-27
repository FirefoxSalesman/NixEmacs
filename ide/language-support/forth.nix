{ lib, config, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.forth.enable = lib.mkEnableOption "enables forth support";

  config = lib.mkIf ide.languages.forth.enable {
    programs.emacs.init.usePackage.forth-mode = {
      enable = true;
      babel = lib.mkIf ide.languages.org.enable "forth";
      mode = [''"\\.fs\\'"''];
      symex = ide.symex;
    };
  };
}
