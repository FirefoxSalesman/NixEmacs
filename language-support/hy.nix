{ pkgs, lib, config, ... }:
# This module is blatantly stolen from doom emacs

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.hy.enable = lib.mkEnableOption "enables hy support";

  config = lib.mkIf ide.languages.hy.enable {
    programs.emacs.init.usePackage.hy-mode = {
      enable = true;
      mode = [''"\\.hy\\'"''];
      symex = ide.symex;
      extraConfig = '':interpreter "hy"'';
    };
  };
}
