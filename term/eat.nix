{ lib, config, ... }:

let
  terminals = config.programs.emacs.init.terminals;
in
{
  options.programs.emacs.init.terminals.eat = lib.mkEnableOption "Enables eat as your terminal.";

  config.programs.emacs.init.usePackage.eat = lib.mkIf terminals.eat {
    enable = true;
    command = ["eat"];
    hook = ["(eshell-mode . eat-eshell-mode)"];
    generalOne.global-leader."t" = lib.mkIf (config.programs.emacs.init.keybinds.leader-key.enable && !terminals.eshell) "'eat";
    config = ''
      ${if config.programs.emacs.init.keybinds.evil.enable then ''(evil-ex-define-cmd "term" 'eat)'' else ""}
      (defun eat-term-get-suitable-term-name (&optional display)
        "Return the most suitable value for `TERM' for DISPLAY.
      
          If the number of colors supported by display (as returned by
          `display-color-cells') is more than 256, return \"eat-truecolor\", if
          it is more than 8 but less than or equal to 256, return
          \"eat-256color\", if is more than 1 but less than or equal to 8,
          return \"eat-color\", otherwise return \"eat-mono\"."
        (let ((colors (display-color-cells display)))
          (cond ((> colors 256) "xterm")
                ((> colors 8) "xterm")
                ((> colors 1) "xterm")
                (t "xterm"))))
    '';
  };
}
