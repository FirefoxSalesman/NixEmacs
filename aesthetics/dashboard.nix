{ config, lib, ... }:

let
  aesthetics = config.programs.emacs.init.aesthetics;
in
{
  options.programs.emacs.init.aesthetics.dashboard.enable =
    lib.mkEnableOption "Enables a dashboard on Emacs startup.";

  config.programs.emacs.init = {
    hasOn = true;
    usePackage.dashboard = lib.mkIf aesthetics.dashboard.enable {
      enable = true;
      ghookf = [ "('on-init-ui '(dashboard-insert-startupify-lists dashboard-initialize))" ];
      config = ''
                (dashboard-setup-startup-hook)
                (dashboard-open)
        	${
           if config.programs.emacs.init.keybinds.evil.enable then
             ''
               (evil-collection-dashboard-setup)
               (evil-collection-dashboard-setup-jump-commands)
               	''
           else
             ""
         }
      '';
      setopt = {
        dashboard-icon-type = lib.mkIf aesthetics.icons.enable (lib.mkDefault "'nerd-icons");
        dashboard-set-heading-icons = lib.mkDefault aesthetics.icons.enable;
        dashboard-set-file-icons = lib.mkDefault aesthetics.icons.enable;
        dashboard-center-content = lib.mkDefault true;
        dashboard-agenda-sort-strategy = lib.mkDefault "'(time-up)";
        dashboard-items = lib.mkDefault [
          "'(recents . 5)"
          "'(bookmarks . 5)"
          "'(projects . 5)"
          "'(agenda . 5)"
        ];
      };
    };
  };
}
