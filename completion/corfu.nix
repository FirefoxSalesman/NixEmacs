{ config, lib, ... }:

let
  completions = config.programs.emacs.init.completions;
  keybinds = config.programs.emacs.init.keybinds;
  mkDisableOption = desc: lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = desc;
  };
in
{
  options.programs.emacs.init.completions.corfu = {
    enable = lib.mkEnableOption "Enables corfu for in-buffer completion. Much is borrowed from Doom & Gavin Freeborn's config.";
    wantTabComplete = mkDisableOption "Enables tab completion. Defaults to true";
    wantRetConfirm = mkDisableOption "Enables return completion. Defaults to true. If set to false, S-return will be used instead. Blatantly plagiarized from doom.";
    wantMinibuffer = lib.mkEnableOption "Enables corfu in the minibuffer";
    popupInfo = lib.mkEnableOption "Enables corfu-popupinfo";
  };

  config.programs.emacs.init = lib.mkIf completions.corfu.enable {
    hasOn = true;
    usePackage = {
      corfu = {
        enable = true;
        hook = [
          "(on-first-buffer . global-corfu-mode)"
          (lib.mkIf completions.corfu.wantMinibuffer "(minibuffer-setup . corfu-enable-in-minibuffer)")
        ];
        custom = {
          corfu-cycle = true;
          corfu-autodelay = "0";
          corfu-auto-prefix = "2";
          corfu-auto = true;
          corfu-on-exact-match = "'show";
        };
        bind."M-/" = "completion-at-point";
        bindLocal.corfu-map = {
          "RET" = lib.mkIf (!completions.corfu.wantRetConfirm) "nil";
          "TAB" = lib.mkIf (!completions.corfu.wantTabComplete) "nil";
          "S-<return>" = lib.mkIf (!completions.corfu.wantRetConfirm) "corfu-insert";
          "S-SPC" = lib.mkIf (!keybinds.evil.enable) "corfu-insert-separator";
          "C-e" = lib.mkIf (!keybinds.evil.enable) "corfu-next";
          "C-p" = lib.mkIf (!keybinds.evil.enable) "nil";
          "C-o" = lib.mkIf (!keybinds.evil.enable) "corfu-previous";
        };
        preface = lib.mkIf completions.corfu.wantMinibuffer ''
          (defun corfu-enable-in-minibuffer ()
            "Enable Corfu in the minibuffer."
            (when (local-variable-p 'completion-at-point-functions)
              (setq-local corfu-auto t) ;; Enable/disable auto completion
              (corfu-mode 1)))
        '';
        generalTwo.":ie".corfu-map = lib.mkIf keybinds.evil.enable {
          "S-SPC" = "'corfu-insert-separator";
          "C-${keybinds.evil.keys.down}" = "'corfu-next";
          "C-p" = "nil";
          "C-${keybinds.evil.keys.up}" = "'corfu-previous";
        };
      };
      
      corfu-popupinfo = {
        enable = true;
        hook = ["(corfu-mode . corfu-popupinfo-mode)"];
      };
      
      corfu-prescient = lib.mkIf completions.prescient {
        enable = true;
        defer = true;
        hook = ["(corfu-mode . corfu-prescient-mode)"];
        custom.corfu-prescient-completion-styles = lib.mkDefault (if completions.orderless then "'(orderless basic prescient)" else "'(basic prescient)");
      };

      corfu-quick = lib.mkIf keybinds.avy.enable {
        enable = true;
        generalTwo.":ie".corfu-map = lib.mkIf keybinds.evil.enable {
          "${keybinds.avy.evilModifierKey}-${keybinds.evil.keys.up}" = lib.mkDefault "'corfu-quick-insert";
          "${keybinds.avy.evilModifierKey}-${keybinds.evil.keys.down}" = lib.mkDefault "'corfu-quick-insert";
        };
        bindLocal.corfu-map."M-g f" = lib.mkIf (!keybinds.evil.enable) "corfu-quick-insert";
      };
    };
  };
}
