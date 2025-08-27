{ lib, config, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.prolog.enable =
    lib.mkEnableOption "enables prolog support. If you are using flymake, consider installing swi prolog so you can have syntax checking";

  config = lib.mkIf ide.languages.prolog.enable {
    programs.emacs.init.usePackage = {
      prolog-mode = {
        enable = true;
        mode = [ ''"\\.pl$"'' ];
      };

      flymake-swi-prolog = lib.mkIf ide.flymake.enable {
        enable = true;
        after = [ "prolog-mode" ];
        hook = [ "(prolog-mode . flymake-mode)" ];
      };
    };
  };
}
