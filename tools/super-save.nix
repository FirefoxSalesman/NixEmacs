{
  config,
  lib,
  ...
}:

let
  tools = config.programs.emacs.init.tools;
in
{
  options.programs.emacs.init.tools.superSave.enable = lib.mkEnableOption "Enables super-save-mode.";

  config.programs.emacs.init = lib.mkIf tools.superSave.enable {
    hasOn = true;
    usePackage.super-save = {
      enable = true;
      hook = [ "(on-first-file . super-save-mode)" ];
      setopt = {
        super-save-auto-save-when-idle = lib.mkDefault true;
        auto-save-default = lib.mkDefault false;
        super-save-silent = lib.mkDefault true;
        super-save-delete-trailing-whitespace = lib.mkDefault true;
      };
    };
  };
}
