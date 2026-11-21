{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.dap.enable = lib.mkEnableOption "Enable dap-mode";

  config.programs.emacs.init.usePackage.dap-mode = lib.mkIf ide.dap.enable {
    enable = true;
    nhook = [
      {
        names = [ "lsp-mode" ];
        actions = [ "'dap-mode" ];
      }
      {
        names = [ "dap-mode" ];
        actions = [ "(lambda () (dap-ui-mode) (dap-tooltip-mode) (dap-ui-controls-mode))" ];
      }
    ];
    bindLocal.ctl-x-map."C-a" = lib.mkDefault "dap-debug";
  };
}
