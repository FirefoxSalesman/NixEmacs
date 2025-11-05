{
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.copilot = {
    enable = lib.mkEnableOption "Enable Copilot completions";
    keepOutOf = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Major modes Copilot shouldn't be enabled in.";
    };
  };

  config.programs.emacs.init.usePackage.copilot = lib.mkIf ide.copilot.enable {
    enable = true;
    hook = [
      ''
        (prog-mode . (lambda ()
        	                     (when (length= (-filter 'major-mode? '(${
                                lib.concatMapStrings (k: "${k} ") ide.copilot.keepOutOf
                              })) 0)
        	                       (copilot-mode))))
      ''
    ];
    bindLocal.copilot-completion-map = {
      "TAB" = lib.mkDefault "copilot-accept-completion";
      "<tab>" = lib.mkDefault "copilot-accept-completion";
      "C-i" = lib.mkDefault "copilot-accept-completion";
    };
  };
}
