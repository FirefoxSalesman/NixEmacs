{ lib, config, ... }:

let
  makeRenames =
    vs:
    lib.optionals (vs != { }) (
      lib.concatStringsSep "\n" (lib.mapAttrsToList (n: v: "(\"${n}\" ${v})") vs)
    );
  makeBinds = vs: lib.optionals (vs != { }) (lib.mapAttrsToList (n: v: "`([${n}] . ${v})") vs);
  tools = config.programs.emacs.init.tools;
in
{
  options.programs.emacs.init.tools.exwm = {
    enable = lib.mkEnableOption "Enables exwm";
    useGaps = lib.mkEnableOption "Enables gaps around the emacs frame";
    wantMouseWarping = lib.mkEnableOption "Enables mouse warping to the center of the focused window";
    bindings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Keybindings for exwm. Left hand side is the key, right hand side is the command. Exported in the form ([key] . command). These items are syntax quoted for your convenience. In order to use a modifier key, you must prefix the modifier with \\?";
    };
    titleAlterations = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Alternate titles for exwm buffers. Left hand side is the buffer's exwm-class-name. Right hand side is the lisp code to generate the new title.";
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
          )
          ++ (
            if tools.exwm.titleAlterations != { } then
              [
                ''
                  (exwm-update-title . (lambda ()
                                                    (pcase exwm-class-name
                                                           ${makeRenames tools.exwm.titleAlterations})))
                ''
              ]
            else
              [ ]
          );
        custom = {
          exwm-workspace-warp-cursor = lib.mkDefault tools.exwm.wantMouseWarping;
          exwm-input-global-keys = makeBinds tools.exwm.bindings;
          exwm-layout-show-all-buffers = lib.mkDefault true;
          exwm-workspace-show-all-buffers = lib.mkDefault true;
        };
      };

      exwm-mff = lib.mkIf tools.exwm.wantMouseWarping {
        enable = true;
        defer = true;
        hook = [ "(exwm-wm-mode . exwm-mff-mode)" ];
      };

      exwm-outer-gaps = lib.mkIf tools.exwm.useGaps {
        enable = true;
        config = "(ignore-errors (exwm-outer-gaps-mode))";
        after = [ "exwm" ];
      };
    };
  };
}
