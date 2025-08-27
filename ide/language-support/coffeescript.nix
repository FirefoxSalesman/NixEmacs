{ pkgs, lib, config, ... }:

{
  options.programs.emacs.init.ide.languages.coffeescript.enable = lib.mkEnableOption "Enables coffeescript support.";

  config = lib.mkIf config.programs.emacs.init.ide.languages.coffeescript.enable {
    programs.emacs.init.usePackage = {
      coffee-mode = {
        enable = true;
        hook = ["(coffee-mode . coffee-cos-mode)"];
      };

      flymake-coffee = {
        enable = true;
        extraPackages = [pkgs.coffeescript];
        hook = ["(coffee-mode . flymake-coffee-load)"];
      };
    };
  };
}
