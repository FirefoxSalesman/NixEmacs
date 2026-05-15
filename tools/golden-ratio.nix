{ config, lib, ... }:
let
  tools = config.programs.emacs.init.tools;
in
{
  options.programs.emacs.init.tools.goldenRatio =
    lib.mkEnableOption "Enables golden-ratio-mode, which automatically resizes windows for you.";

  config.programs.emacs.init = lib.mkIf tools.goldenRatio {
    hasOn = true;
    usePackage.golden-ratio = {
      enable = true;
      hook = [ "(on-first-input . golden-ratio-mode)" ];
      config = lib.mkIf tools.exwm.wantMouseWarping "(advice-add 'golden-ratio :after 'exwm-mff-warp-to-selected)";
    };
  };
}
