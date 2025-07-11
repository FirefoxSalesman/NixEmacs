{ pkgs, lib, config, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.prolog.enable = lib.mkEnableOption "enables prolog support";

  config = lib.mkIf ide.languages.prolog.enable {
    programs.emacs.init.usePackage.prolog-mode = {
      enable = true;
      mode = [''"\\.pl$"''];
    };
  };
}
