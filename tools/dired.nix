{ config, lib, ... }:

let
  tools = config.programs.emacs.init.tools;
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.tools.dired = {
    enable = lib.mkEnableOption "Enable dired improvements.";
    narrow = lib.mkEnableOption "Enable dired-narrow.";
    posframe = lib.mkEnableOption "Enable dired-posframe.";
  };

  config.programs.emacs.init.usePackage = lib.mkIf tools.dired.enable {
    dired = {
      enable = true;
      hook = ["(dired-mode . (lambda () (dired-omit-mode) (hl-line-mode) (setq-local visible-cursor nil)))"];
      setopt = {
	dired-recursive-deletes = lib.mkDefault "'always";
        dired-listing-switches = lib.mkDefault ''"-agho --group-directories-first"'';
      };
      generalOne.global-leader."d" = lib.mkIf keybinds.leader-key.enable '''("dired" . dired)'';
      bindLocal.ctl-x-map."C-j" = lib.mkDefault "dired-jump";
    };

    wdired = {
      enable = true;
      generalTwoConfig.":n".dired-mode-map."w" = lib.mkIf keybinds.evil.enable (lib.mkDefault "'wdired-change-to-wdired-mode");
      bindLocal.dired-mode-map."w" = lib.mkIf (!keybinds.evil.enable) (lib.mkDefault "wdired-change-to-wdired-mode");
    };

    diredfl = {
      enable = true;
      hook = ["(dired-mode . diredfl-mode)"];
    };

    dired-narrow = lib.mkIf tools.dired.narrow {
      enable = true;
      generalTwo.":n".dired-mode-map."N" = lib.mkIf keybinds.evil.enable (lib.mkDefault "'dired-narrow-fuzzy");
      bindLocal.dired-mode-map."N" = lib.mkIf (!keybinds.evil.enable) (lib.mkDefault "dired-narrow-fuzzy");
    };

    dired-posframe = lib.mkIf tools.dired.posframe {
      enable = true;
      generalTwo.":n".dired-mode-map."M-t" = lib.mkIf keybinds.evil.enable (lib.mkDefault "'dired-posframe-mode");
      bindLocal.dired-mode-map."M-t" = lib.mkIf (!keybinds.evil.enable) (lib.mkDefault "dired-posframe-mode");
    };

    dired-hide-dotfiles = {
      enable = true;
      hook = ["(dired-mode . dired-hide-dotfiles-mode)"];
      generalTwoConfig.":n".dired-mode-map."H" = lib.mkIf keybinds.evil.enable (lib.mkDefault "'dired-hide-dotfiles-mode");
      bindLocal.dired-mode-map."H" = lib.mkIf (!keybinds.evil.enable) (lib.mkDefault "dired-hide-dotfiles-mode");
    };
  } ;
}
