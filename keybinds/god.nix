{ lib, config, ... }:

let
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.keybinds.god.enable =
    lib.mkEnableOption "Enables god-mode. (Borrowed from doom)";

  config.programs.emacs.init = lib.mkIf keybinds.god.enable {
    hasOn = lib.mkIf (!keybinds.evil.enable) true;
    usePackage = {
      god-mode = {
        enable = true;
        hook = lib.mkIf (!keybinds.evil.enable) [ "(on-init-ui-hook . god-mode-all)" ];
        setopt = {
          god-exempt-major-modes = false;
          god-exempt-predicates = false;
        };
        preface = lib.mkIf (!keybinds.evil.enable) ''
          (defun toggle-god-mode ()
                 "Toggles god-local-mode."
                 (interactive)
                 (if god-local-mode
                     (god-local-mode-pause)
                     (god-local-mode-resume)))
        '';
        bindLocal.god-local-mode-map."<escape>" = lib.mkIf (!keybinds.evil.enable) "toggle-god-mode";
        bind."<escape>" = lib.mkIf (!keybinds.evil.enable) "toggle-god-mode";
        config = lib.mkIf keybinds.whichKey.enable "(with-eval-after-load 'which-key (which-key-enable-god-mode-support))";
      };

      evil-god-state = lib.mkIf keybinds.evil.enable {
        enable = true;
        command = [ "evil-god-state" ];
        gfhookf = lib.mkIf keybinds.doomEscape.enable [ "('doom-escape 'evil-god-state-bail)" ];
        generalOne = {
          ":n"."," = "'evil-execute-in-god-state";
          ":e"."<escape>" = "'evil-god-state";
        };
        generalOneConfig.evil-god-state-map = {
          "<escape>" = "'evil-god-state-bail";
          "<return>" = "'evil-emacs-state";
        };
      };
    };
  };
}
