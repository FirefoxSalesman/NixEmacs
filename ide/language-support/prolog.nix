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
        generalTwoConfig."local-leader".prolog-mode-map."r" =
          lib.mkIf config.programs.emacs.init.keybinds.leader-key.enable (lib.mkDefault "'run-prolog");
      };

      flymake-swi-prolog = lib.mkIf ide.flymake.enable {
        enable = true;
        after = [ "prolog-mode" ];
        hook = [ "(prolog-mode . flymake-mode)" ];
      };

      ob-prolog = lib.mkIf ide.languages.org.enable {
        enable = true;
        babel = lib.mkIf ide.languages.org.enable "prolog";
      };
    };
  };
}
