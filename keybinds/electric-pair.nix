{ config, lib, ... }:

let
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.keybinds.electricPair.enable =
    lib.mkEnableOption "Enables electric-pair-mode. Borrowed from Derek Taylor.";

  config.programs.emacs.init = lib.mkIf keybinds.electricPair.enable {
    hasOn = true;
    usePackage.elec-pair = {
      enable = true;
      hook = [ "(on-first-buffer . electric-pair-mode)" ];
      setopt = {
        electric-pair-pairs = lib.mkDefault [
          '''(?\" . ?\")''
          '''(?\[ . ?\])''
          '''(?\( . ?\))''
          '''(?\{ . ?\})''
        ];
        # < & > are not delimiters. Change my mind.
        # Courtesy of DT. https://gitlab.com/dwt1/configuring-emacs/-/tree/main/07-the-final-touches?ref_type=heads
        electric-pair-inhibit-predicate = lib.mkDefault ''
          `(lambda (c)
                    	  (if (or (char-equal c ?<) (char-equal c ?>))
                    	      t
                    	      (,electric-pair-inhibit-predicate c)))
        '';
      };
    };
  };
}
