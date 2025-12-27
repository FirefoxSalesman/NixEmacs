{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.treesit-fold = {
    enable = lib.mkEnableOption "Enable code folding via treesitter";
    enabledModes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "bash-ts-mode"
        "emacs-lisp-mode"
      ];
      description = "List of major modes to enable treesit-fold-mode in.";
    };
  };
  config.programs.emacs.init.usePackage.treesit-fold = lib.mkIf ide.treesit-fold.enable {
    enable = true;
    hook = lib.map (mode: "(${mode} . treesit-fold-mode)") ide.treesit-fold.enabledModes;
  };
}
