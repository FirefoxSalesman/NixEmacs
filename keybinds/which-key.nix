{ config, lib, ... }:

let
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.keybinds.whichKey = {
    enable = lib.mkEnableOption "Enables which-key";
    posframe = {
      enable = lib.mkEnableOption "Creates a posframe popup for which-key";
      unparent = lib.mkEnableOption "Posframe is in a new frame (useful for exwm)";
    };
  };

  config.programs.emacs.init = lib.mkIf keybinds.whichKey.enable {
    hasOn = true;
    usePackage = {
      which-key = {
        enable = true;
        hook = [ "(on-first-input . which-key-mode)" ];
        setopt.which-key-idle-delay = lib.mkDefault 1.0;
      };

      which-key-posframe = lib.mkIf keybinds.whichKey.posframe.enable {
        enable = true;
        defer = true;
        hook = [ "(which-key-mode . which-key-posframe-mode)" ];
        setopt.which-key-posframe-poshandler = "'posframe-poshandler-frame-bottom-center";
        config = lib.mkIf keybinds.whichKey.posframe.unparent ''
          (defun which-key-posframe--show-buffer (act-popup-dim)
             "Show which-key buffer when popup type is posframe.
           Argument ACT-POPUP-DIM has the form (HEIGHT . WIDTH), specifying
           the dimensions of the buffer text to be displayed in the popup."
             (when (posframe-workable-p)
               (save-window-excursion
                 (posframe-show
                  which-key--buffer
                  :font which-key-posframe-font
                  :position (point)
                  :poshandler which-key-posframe-poshandler
                  :background-color (face-attribute 'which-key-posframe :background nil t)
                  :foreground-color (face-attribute 'which-key-posframe :foreground nil t)
                  :height (car act-popup-dim)
                  :width (cdr act-popup-dim)
                  :lines-truncate t
                  :internal-border-width which-key-posframe-border-width
                  :internal-border-color (face-attribute 'which-key-posframe-border
                                                         :background nil t)
                  :parent-frame nil :refposhandler 'posframe-refposhandler-xwininfo
                  :override-parameters which-key-posframe-parameters))))
        '';
      };
    };
  };
}
