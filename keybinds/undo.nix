{ lib, config, ... }:

let
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.keybinds.undo.enable =
    lib.mkEnableOption "Enables undo-fu, granting us linear undos";

  config.programs.emacs.init = {
    hasOn = true;
    usePackage.undo-fu = lib.mkIf keybinds.undo.enable {
      enable = true;
      setopt.undo-fu-session-compression = "'zst";
      afterCall = [ "on-first-buffer-hook" ];
    };
  };
}
