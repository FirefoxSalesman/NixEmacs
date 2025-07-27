{ pkgs, config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.lsp-bridge.enable = lib.mkEnableOption
    "Enable lsp-bridge's preset configuration. (A total of 2 changed variables) & enables it for language support";

  config = lib.mkIf ide.lsp-bridge.enable {
    programs.emacs = {
      extraPackages = [epkgs.on];
      init.usePackage.lsp-bridge = {
        enable = true;
        init = "(require 'on)";
        custom = {
          lsp-bridge-get-workspace-folder = lib.mkDefault "'project-root";
          lsp-bridge-enable-org-babel = lib.mkDefault "t";
        };
        afterCall = [ "on-first-input-hook" ];
        config = "(global-lsp-bridge-mode)";
      };
    };
  };
}
