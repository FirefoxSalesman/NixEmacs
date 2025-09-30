{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.makefile.enable = lib.mkEnableOption "Enables Makefile support";
  config.programs.emacs.init.usePackage.make-mode = lib.mkIf ide.languages.makefile.enable {
    enable = true;
    symex = ide.symex;
    ghookf = lib.mkIf ide.symex ["('makefile-mode (treesit! 'make))"];
  };
}
