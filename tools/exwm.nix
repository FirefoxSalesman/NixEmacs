{ lib, config, ... }:

let
  # makeBinds = vs: lib.optionals (vs != { }) (lib.mapAttrsToList (n: v: "`([?\${n}] . ${v})"));
  tools = config.programs.emacs.init.tools;
  # bindType =
  #   desc:
  #   lib.mkOption {
  #     type = lib.types.attrsOf lib.types.str;
  #     default = { };
  #     description =
  #       desc
  #       + " Exported in the form ([?\\key] . command). These items are syntax quoted for your convenience.";
  #   };
in
{
  options.programs.emacs.init.tools.exwm = {
    enable = lib.mkEnableOption "Enables exwm";
    useGaps = lib.mkEnableOption "Enables gaps around the emacs frame";
    wantMouseWarping = lib.mkEnableOption "Enables mouse warping to the center of the focused window";
    # bindings = bindType "Keybindings for exwm. Left hand side is the key, right hand side is the command.";
    # simulationKeys = bindType "Simulation keys for exwm. Left hand side is the original key, right hand side is the new key.";
  };

  config.programs.emacs.init = {
    hasOn = true;
    usePackage = lib.mkIf tools.exwm.enable {
      exwm = {
        enable = true;
        afterCall = [ "on-init-ui-hook" ];
        custom = {
          exwm-workspace-warp-cursor = lib.mkDefault tools.exwm.wantMouseWarping;
          # exwm-input-global-keys = makeBinds tools.exwm.bindings;
          # exwm-input-simulation-keys = makeBinds tools.exwm.simulationKeys;
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
