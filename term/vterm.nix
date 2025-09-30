{ config, lib, ... }:

let
  terminals = config.programs.emacs.init.terminals;
in
{
  options.programs.emacs.init.terminals.vterm = lib.mkEnableOption "Enables vterm.";

  config.programs.emacs.init.usePackage.vterm = lib.mkIf terminals.vterm {
    enable = true;
    command = ["vterm"];
    generalOne.global-leader."t" = lib.mkIf config.programs.emacs.init.keybinds.leader-key.enable "'vterm";
  };
}
