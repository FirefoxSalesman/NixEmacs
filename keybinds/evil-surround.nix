{ config, lib, ... }:

let
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.keybinds.evil.surround = lib.mkEnableOption "Enables evil-surround";

  config.programs.emacs.init.usePackage.evil-surround = lib.mkIf keybinds.evil.surround {
    enable = true;
    deferIncrementally = true;
    config = "(global-evil-surround-mode)";
  };
}
