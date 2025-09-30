{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.pug.enable = lib.mkEnableOption "enables pug support";

  config.programs.emacs.init.usePackage.pug-mode = lib.mkIf ide.languages.pug.enable {
    enable = true;
    mode = [ ''"\\.pug\\'"'' ];
  };
}
