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
        nhook = [
          {
            names = [ "coffee-mode" ];
            actions = [ "'coffee-cos-mode" ];
          }
        ];
      };

      flymake-coffee = lib.mkIf ide.flymake.enable {
        enable = true;
        extraPackages = [ pkgs.coffeescript ];
        nhook = [
          {
            names = [ "coffee-mode" ];
            actions = [ "'flymake-coffee-load" ];
          }
        ];
      };

      ob-coffeescript = lib.mkIf ide.languages.org.enable {
        enable = true;
        after = [ "org" ];
        babel = lib.mkIf ide.languages.org.enable "coffeescript";
      };
    };
  };
}
