{ config, lib, ... }:

{
  options.programs.emacs.init.ide.direnv = lib.mkEnableOption "Enable direnv support";

  config.programs = lib.mkIf config.programs.emacs.init.ide.direnv {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    
    emacs.init.usePackage.envrc = {
      enable = true;
      hook = ["(after-init . envrc-global-mode)"];
      generalOne.global-leader = lib.mkIf config.programs.emacs.init.keybinds.leader-key.enable {
        "e" = lib.mkDefault '''(:ignore t :which-key "direnv")'';
        "ea" = lib.mkDefault "'envrc-allow";
        "eu" = lib.mkDefault "'envrc-reload";
        "ed" = lib.mkDefault "'envrc-deny";
      };
    };
  };
}
