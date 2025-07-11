{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.zenscript.enable = lib.mkEnableOption "enables zenscript support";

  config = lib.mkIf ide.languages.zenscript.enable {
    programs.emacs.init.usePackage.zenscript-mode = {
      enable = true;
      mode = [''"\\.zs\\'"''];
      # There's no way we're fixing the completion system, so we'll turn it off
      config = ''
        (defun zenscript-get-dumpzs (&optional prompt)
          "Returns nothing, because I can't fix the dumpfile problem"
          '(() . ()))
      '';
    };
  };
}
