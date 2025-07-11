{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.pug.enable = lib.mkEnableOption "enables pug support";

  config = lib.mkIf ide.languages.pug.enable {
    programs.emacs.init.usePackage.pug-mode = {
      enable = ide.web.pug;
      mode = [''"\\.pug\\'"''];
    };
  };
}
