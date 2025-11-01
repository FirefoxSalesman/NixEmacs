{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.lsp-bridge.enable =
    lib.mkEnableOption "Enable lsp-bridge's preset configuration. (A total of 2 changed variables) & enables it for language support";

  config = lib.mkIf ide.lsp-bridge.enable {
    programs.emacs = {
      extraPackages = epkgs: with epkgs; [ on ];
      init.usePackage.lsp-bridge = {
        enable = true;
        init = "(require 'on)";
        setopt = {
          lsp-bridge-get-workspace-folder = lib.mkDefault "'project-root";
          lsp-bridge-enable-org-babel = lib.mkDefault true;
        };
        afterCall = [ "on-first-input-hook" ];
        config = "(global-lsp-bridge-mode)";
        generalTwoConfig.local-leader.lsp-bridge-mode =
          lib.mkIf config.programs.emacs.init.keybinds.leader-key.enable
            {
              "r" = lib.mkDefault "'lsp-bridge-rename";
              "a" = lib.mkDefault "'lsp-bridge-code-action";
            };
      };
    };
  };
}
