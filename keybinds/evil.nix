{ pkgs, config, lib, ... }:

let
  keybinds = config.programs.emacs.init.keybinds;
  mkBindOption = key: desc: lib.mkOption {
    type = lib.types.string;
    default = key;
    description = "binding for evil-${desc}";
  };
  matches = p: n: lib.match p n != null;
  generalDef = key: command: ''(general-def '(operator normal visual motion) "${key}" 'evil-${command})'';
  mkBinding = key: original: command: if matches key original then "" else generalDef key command;
  visualBinding = key: original: visCommand: altCommand: if keybinds.evil.keys.prefer-visual-line then generalDef key visCommand else mkBinding key original altCommand;
in
{
  options.programs.emacs.init.keybinds.evil = {
    enable = lib.mkEnableOption "Enables evil-mode. Universal argument is moved to M-u.";
    keys = {
      forward = mkBindOption "l" "forward-char";
      backward = mkBindOption "h" "backward-char";
      up = mkBindOption "k" "previous-line";
      down = mkBindOption "j" "next-line";
      prefer-visual-line = lib.mkEnableOption "Switches evil-next-line & evil-previous-line for evil-next-visual-line & evil-previous-visual-line";
    };
  };
  config.programs.emacs.init = lib.mkIf keybinds.evil.enable {
    usePackage = {
      evil = {
        enable = true;
        demand = true;
        custom = {
          # Various settings to make it more like vim
          evil-want-integration = true;
          evil-want-keybinding = false;
          evil-want-minibuffer = true;
          evil-want-C-u-scroll = true;
          evil-want-C-w-delete = true;
          evil-want-C-u-delete = true;
          evil-want-C-h-delete = true;
          evil-want-C-i-jump = true;
          evil-move-cursor-back = false;
          evil-move-beyond-eol = true; # Combined with move-cursor-back, it prevents the cursor from moving behind a "/" when selecting a directory in the minibuffer
          evil-cross-lines = true;
          sentence-end-double-space = false;
        };
        general."M-u" = "'universal-argument";
        generalOne.universal-argument-map = {
          "M-u" = "'universal-argument-more";
          "C-u" = "'nil";
        };

        config = ''
          (evil-mode)
          (setq evil-want-Y-yank-to-eol t)
          (evil-set-undo-system 'undo-redo)
          (evil-set-initial-state 'messages-buffer-mode 'normal)
          (general-advice-add '(evil-scroll-down evil-scroll-up evil-scroll-page-up evil-scroll-page-down) :after #'(lambda (arg) (evil-window-middle)))
          (evil-add-command-properties #'flymake-goto-next-error :jump t)
          (evil-add-command-properties #'flymake-goto-prev-error :jump t)
          (evil-add-command-properties #'evil-scroll-up :jump t)
          (evil-add-command-properties #'evil-scroll-down :jump t)
          ${mkBinding keybinds.evil.keys.forward "l" "forward-char"}
          ${mkBinding keybinds.evil.keys.backward "h" "backward-char"}
          ${visualBinding keybinds.evil.keys.up "k" "previous-visual-line" "previous-line"}
          ${visualBinding keybinds.evil.keys.down "j" "next-visual-line" "next-line"}
        '';
      };
    };
  };
}
