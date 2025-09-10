{
  pkgs,
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.xml.enable = lib.mkEnableOption "Enables xml support.";

  config = lib.mkIf ide.languages.xml.enable {
    programs.emacs.init = {
      ide.treesitterGrammars."xml" = "https://github.com/ObserverOfTime/tree-sitter-xml";
      usePackage.nxml = {
        enable = true;
        mode = [ ''("\\.xml\\'" . nxml-mode)'' ];
	symex = ide.symex;
      };
    };
  };
}
