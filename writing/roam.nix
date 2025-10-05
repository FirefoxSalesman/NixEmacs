{ lib, config, pkgs, ... }:

let
  completions = config.programs.emacs.init.completions;
  keybinds = config.programs.emacs.init.keybinds;
  writing = config.programs.emacs.init.writing;
in
{
  options.programs.emacs.init.writing.orgRoam = lib.mkEnableOption "Enables org-roam as your note taking system. Largely borrowed from Doom.";

  config.programs.emacs.init.usePackage = lib.mkIf writing.orgRoam {
    org-roam = {
      enable = true;
      setopt = {
	org-roam-directory = lib.mkDefault ''(expand-file-name "roam" org-directory)'';
	org-roam-buffer-window-parameters = lib.mkDefault ["'(no-delete-other-windows . t)"];
	org-roam-link-use-custom-faces = lib.mkDefault "'everywhere";
	org-roam-completion-everywhere = lib.mkDefault true;
	org-roam-completion-system = lib.mkDefault (if completions.helm.enable then "'helm" else
	if completions.ivy.enable then "'ivy" else
	"'default");
      };
      generalOne.global-leader = lib.mkIf keybinds.leader-key.enable {
	"of" = lib.mkIf (!completions.smallExtras.enable) (lib.mkDefault "'org-roam-find-file");
	"oi" = lib.mkDefault "'org-roam-insert";
	"og" = lib.mkDefault "'org-roam-graph";
      };
      config = "(org-roam-db-autosync-mode)";
    };

    consult-org-roam = lib.mkIf completions.smallExtras.enable {
      enable = true;
      consult-org-roam-grep-func = "#'consult-ripgrep";
      generalOne.global-leader = lib.mkIf keybinds.leader-key.enable {
	"of" = lib.mkDefault "'consult-org-roam-file-find";
	"os" = lib.mkDefault "'consult-org-roam-search";
      };
    };
  };
}
