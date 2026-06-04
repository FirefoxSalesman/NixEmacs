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

  programs.emacs.init.usePackage.super-save = lib.mkIf tools.superSave.enable {
    enable = true;
    hook = [ "(on-first-file . super-save-mode)" ];
    setopt = {
      super-save-auto-save-when-idle = true;
      auto-save-default = false;
      super-save-silent = true;
      super-save-delete-trailing-whitespace = true;
    };
  };
}
