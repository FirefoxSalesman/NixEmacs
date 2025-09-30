{ config, lib, ... }:

let
  completions = config.programs.emacs.init.completions;
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.completions.mct.enable = lib.mkEnableOption "Enables mct. Stolen from Prot.";

  config.programs.emacs.init = lib.mkIf completions.mct.enable {
    hasOn = true;
    usePackage.mct = {
      enable = true;
      hook = ["(on-first-input . mct-mode)"];
      custom = {
	mct-hide-completion-mode-line = lib.mkDefault true;
	mct-completing-read-multiple-indicator = lib.mkDefault true;
	mct-live-completion = lib.mkDefault "'visible";
	mct-completion-passlist = lib.mkDefault ''
	'(select-frame-by-name
          Info-goto-node
          Info-index
          Info-menu
          vc-retrieve-tag
          ;; Some completion categories
          consult-buffer
          consult-location
          embark-keybinding
          imenu
          file
          project-file
          buffer
          kill-ring)
	'';
      };
      generalTwoConfig.":mnei" = lib.mkIf keybinds.evil.enable {
	mct-minibuffer-local-completion-map = {
	  "C-${keybinds.evil.keys.up}" = lib.mkDefault "'mct-switch-to-completions-bottom";
	  "C-${keybinds.evil.keys.down}" = lib.mkDefault "'mct-switch-to-completions-top";
	};
	mct-minibuffer-completion-list-map = {
	  "C-${keybinds.evil.keys.down}" = lib.mkDefault "'mct-next-completion-or-mini";
	  "C-${keybinds.evil.keys.up}" = lib.mkDefault "'mct-previous-completion-or-mini";
	  "${keybinds.evil.keys.down}" = lib.mkDefault "'mct-next-completion-or-mini";
	  "${keybinds.evil.keys.up}" = lib.mkDefault "'mct-previous-completion-or-mini";
	};
      };
    };
  };
}
