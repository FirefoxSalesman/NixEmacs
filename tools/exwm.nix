{ lib, config, ... }:

let
  makeBinds = vs: lib.optionals (vs != { }) (lib.mapAttrsToList (n: v: "`([${n}] . ${v})") vs);
  tools = config.programs.emacs.init.tools;
in
{
  options.programs.emacs.init.tools.exwm = {
    enable = lib.mkEnableOption "Enables exwm";
    # useGaps = lib.mkEnableOption "Enables gaps around the emacs frame";
    wantMouseWarping = lib.mkEnableOption "Enables mouse warping to the center of the focused window";
    bindings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Keybindings for exwm. Left hand side is the key, right hand side is the command. Exported in the form ([key] . command). These items are syntax quoted for your convenience. In order to use a modifier key, you must prefix the modifier with \\?";
    };
  };

  config.programs.emacs.init = lib.mkIf tools.exwm.enable {
    hasOn = true;
    usePackage = {
      exwm = {
        enable = true;
        afterCall = [ "on-init-ui-hook" ];
        hook =
          [ ]
          ++ (
            if config.programs.emacs.init.keybinds.evil.enable then
              [ "(exwm-mode . evil-motion-state)" ]
            else
              [ ]
          );
        custom = {
          exwm-workspace-warp-cursor = lib.mkDefault tools.exwm.wantMouseWarping;
          exwm-input-global-keys = makeBinds tools.exwm.bindings;
        };
      };

      exwm-mff = lib.mkIf tools.exwm.wantMouseWarping {
        enable = true;
        defer = true;
        hook = [ "(exwm-wm-mode . exwm-mff-mode)" ];
      };
    };
  };
}
