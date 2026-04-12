{ config, lib, ... }:

let
  tools = config.programs.emacs.init.tools;
in
{
  options.programs.emacs.init.tools.noLittering.enable =
    lib.mkEnableOption "Enable no-littering. Borrowed from Emacs from Scratch.";

  config.programs.emacs.init.usePackage.no-littering = lib.mkIf tools.noLittering.enable {
    enable = true;
    demand = true;
    #no-littering doesn't set this by default so we must place
    #auto save files in the same path as it uses for sessions
    setopt.auto-save-file-name-transforms = ''`((".*" ,(no-littering-expand-var-file-name "auto-save/") t))'';
  };
}
