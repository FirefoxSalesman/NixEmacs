{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.makefile.enable =
    lib.mkEnableOption "Enables Makefile support";
  config.programs.emacs.init = lib.mkIf ide.languages.makefile.enable {
    ide = {
      treesitter.wantTreesitter = true;
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "make-mode" ];
    };
    usePackage.make-mode = {
      enable = true;
      symex = ide.symex;
      ghookf = lib.mkIf ide.symex [ "('makefile-mode (treesit! 'make))" ];
    };
  };
}
