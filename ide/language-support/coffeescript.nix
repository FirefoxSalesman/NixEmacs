{
  pkgs,
  lib,
  config,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.coffeescript.enable =
    lib.mkEnableOption "Enables coffeescript support.";

  config = lib.mkIf config.programs.emacs.init.ide.languages.coffeescript.enable {
    programs.emacs.init.usePackage = {
      coffee-mode = {
        enable = true;
        hook = [ "(coffee-mode . coffee-cos-mode)" ];
      };

      flymake-coffee = lib.mkIf ide.flymake.enable {
        enable = true;
        extraPackages = [ pkgs.coffeescript ];
        hook = [ "(coffee-mode . flymake-coffee-load)" ];
      };

      ob-coffeescript = lib.mkIf ide.languages.org.enable {
        enable = true;
        after = [ "org" ];
        babel = ide.languages.org.enable "coffeescript";
      };
    };
  };
}
