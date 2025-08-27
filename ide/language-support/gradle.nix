{ config, lib, ... } :

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.gradle.enable = lib.mkEnableOption "enables groovy-mode, a major mode for editing gradle files";

  config = lib.mkIf ide.languages.gradle.enable {
    programs.emacs.init.usePackage.groovy-mode = {
      enable = true;
      babel = lib.mkIf ide.languages.org.enable "groovy";
      symex = ide.symex;
      mode = [''"\\.gradle\\'"''];
    };
  };
}
