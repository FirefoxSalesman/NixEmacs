{ config, lib, ... }:

let
  keybinds = config.programs.emacs.init.keybinds;
  completions = config.programs.emacs.init.completions;
in
{
  options.programs.emacs.init.keybinds.avy = {
    enable = lib.mkEnableOption "Enables avy support. Many actions borrowed from Karthink.";
    evilModifierKey = lib.mkOption {
      type = lib.types.string;
      default = "M";
      description = "The modifier key to use for evil easymotions";
    };
  };

  config.programs.emacs.init.usePackage = lib.mkIf keybinds.avy.enable {
    avy = {
      enable = true;
      defer = true;
      after = ["isearch"];
      bind = lib.mkIf (!keybinds.evil.enable) {
        "C-:" = lib.mkDefault "avy-goto-char";
        "C-'" = lib.mkDefault "avy-goto-char-2";
      };
      bindLocal = lib.mkIf (!keybinds.evil.enable) {
        goto-map = {
          "f" = lib.mkIf (!completions.vertico.enable) (lib.mkDefault "avy-goto-line");
          "w" = lib.mkDefault "avy-goto-word-1";
          "e" = lib.mkDefault "avy-goto-word-0";
        };
        mode-specific-map."C-j" = lib.mkDefault "avy-resume";
      };
      config = ''
        (avy-setup-default)

        ;; Stolen from karthink
        (defun nix-emacs-base-avy-action (action pt)
          "Runs the function ACTION at PT. Meant to be used for making avy actions."
          (unwind-protect
              (save-excursion
	        (goto-char pt)
	        (funcall action)))
          (select-window
           (cdr (ring-ref avy-ring 0)))
          t)
        
        ${if keybinds.evil.enable then ''
          (defun nix-emacs-avy-action-fold (pt)
                 (nix-emacs-base-avy-action 'evil-toggle-fold pt))
          '' else ""}

        ${if completions.vertico.embark then ''
          (defun nix-emacs-avy-action-embark (pt)
                 (nix-emacs-base-avy-action 'embark-act pt))
          '' else ""}
      '';
      custom.avy-dispatch-alist = lib.mkIf (!keybinds.evil.enable) (lib.mkDefault ''
        '((?x . avy-action-kill-move)
          (?X . avy-action-kill-stay)
          (?t . avy-action-teleport)
          (?m . avy-action-mark)
          (?n . avy-action-copy)
          (?y . avy-action-yank-line)
          (?i . avy-action-ispell)
          (?z . avy-action-zap-to-char)
          ${if completions.vertico.embark then "(?o . nix-emacs-avy-action-embark)" else ""})
      '');
    };

    evil-easymotion = lib.mkIf keybinds.evil.enable {
      enable = true;
      generalOne = {
        ":o" = {
          "/" = "'evil-avy-goto-char-2"; 
          "?" = "'evil-avy-goto-char-2"; 
        };
        ":nvo" = {
          "${keybinds.avy.evilModifierKey}-n" = lib.mkDefault "'evilem-motion-search-next";
          "${keybinds.avy.evilModifierKey}-w" = lib.mkDefault "'evilem-motion-forward-word-begin";
          "${keybinds.avy.evilModifierKey}-W" = lib.mkDefault "'evilem-motion-forward-WORD-begin";
          "${keybinds.avy.evilModifierKey}-b" = lib.mkDefault "'evilem-motion-backward-word-begin";
          "${keybinds.avy.evilModifierKey}-B" = lib.mkDefault "'evilem-motion-backward-WORD-begin";
          "${keybinds.avy.evilModifierKey}-N" = lib.mkDefault "'evilem-motion-search-previous";
          "${keybinds.avy.evilModifierKey}-${keybinds.evil.keys.down}" = lib.mkDefault "'evilem-motion-next-visual-line";
          "${keybinds.avy.evilModifierKey}-${keybinds.evil.keys.up}" = lib.mkDefault "'evilem-motion-previous-visual-line";
        };
      };
      custom.avy-dispatch-alist = lib.mkDefault ''
        '((?t . avy-action-teleport)
          (?y . avy-action-yank)
          (?i . avy-action-ispell)
          (?z . nix-emacs-avy-action-fold)
          ${if completions.vertico.embark then "(?o . nix-emacs-avy-action-embark)" else ""})
      '';
    };
  };
}
