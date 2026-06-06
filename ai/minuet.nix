{ lib, config, ... }:

let
  ai = config.programs.emacs.init.ai;
  evil = config.programs.emacs.init.keybinds.evil;
in
{
  options.programs.emacs.init.ai.minuet.enable = lib.mkEnableOption "Enables minuet completions.";
  config.programs.emacs.init.usePackage.minuet = lib.mkIf ai.minuet.enable {
    enable = true;
    hook = [ "(prog-mode . minuet-auto-suggestion-mode)" ];
    bindLocal.minuet-active-mode-map = {
      "M-${if evil.enable then evil.keys.down else "n"}" = lib.mkDefault "minuet-next-suggestion";
      "M-${if evil.enable then evil.keys.up else "p"}" = lib.mkDefault "minuet-previous-suggestion";
      "C-i" = lib.mkDefault "minuet-accept-suggestion";
      "M-i" = lib.mkDefault "minuet-accept-suggestion-line";
      "M-d" = lib.mkDefault "minuet-dismiss-suggestion";
    };
    setopt = {
      minuet-n-completions = lib.mkDefault 1;
      minuet-context-window = lib.mkDefault 512;
    };
  };
}
