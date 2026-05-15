{ config, lib, ... }:

{
  options.programs.emacs.init.aesthetics.declutter.enable =
    lib.mkEnableOption "Remove screen clutter such as the fringe, tooltips, the scrollbar, the toolbar, & the menubar. Borrowed from Emacs from Scratch.";

  config.programs.emacs.init = lib.mkIf config.programs.emacs.init.aesthetics.declutter.enable {
    earlyInit = ''
      (scroll-bar-mode -1) ; Disable visible scrollbar
      (tool-bar-mode -1) ; Disable the toolbar
      (menu-bar-mode -1)
    '';

    usePackage = {
      tooltip = {
        enable = true;
        config = "(tooltip-mode -1)";
      };

      fringe = {
        enable = true;
        config = "(set-fringe-mode -1)";
      };
    };
  };
}
