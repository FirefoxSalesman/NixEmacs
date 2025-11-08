{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.yara.enable = lib.mkEnableOption "Enables yara support.";

  config.programs.emacs.init.usePackage.yara-mode = lib.mkIf ide.languages.yara.enable {
    enable = true;
    mode = [''"\\.yar\\'"''];
  };
}
