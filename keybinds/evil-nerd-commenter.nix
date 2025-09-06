{ config, lib, ... }:

let
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.keybinds.evilNerdCommenter.enable = lib.mkEnableOption "Enables evil-nerd-commenter. Enabling leader keys is enabled.";

  config.programs.emacs.init.usePackage.evil-nerd-commenter = lib.mkIf keybinds.evilNerdCommenter.enable {
    enable = true;
    generalOne.global-leader = lib.mkIf keybinds.leader-key.enable {
      "c" = lib.mkDefault '''(:ignore t :which-key "comment")'';
      "ci" = lib.mkDefault "'evilnc-comment-or-uncomment-lines";
      "cl" = lib.mkDefault "'evilnc-quick-comment-or-uncomment-paragraphs";
      "cc" = lib.mkDefault "'evilnc-copy-and-comment-lines";
      "cp" = lib.mkDefault "'evilnc-comment-or-uncomment-paragraphs";
      "cr" = lib.mkDefault "'comment-or-uncomment-region";
      "cv" = lib.mkDefault "'evilnc-toggle-invert-comment-line-by-line";
      "cy" = lib.mkDefault "'evilnc-copy-and-comment-operator";
      "co" = lib.mkDefault "'evilnc-comment-operator";
    };
    config = lib.mkIf (!keybinds.evilNerdCommenter.enable) "(evilnc-default-hotkeys)";
  };
}
