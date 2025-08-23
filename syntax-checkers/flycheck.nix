{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.flycheck.preset = lib.mkEnableOption "Enables flycheck's preset options (largely borrowed from doom)";

  config = lib.mkIf ide.flycheck.preset {
    programs.emacs = {
      extraPackages = epkgs: [epkgs.on];
      init.usePackage = {
        flycheck = {
          enable = true;
          hook = ["(on-first-buffer . global-flycheck-mode)"];
          extraConfig = '':preface (require 'on)'';
          custom = {
            flycheck-idle-change-delay = "1.0";
            flycheck-buffer-switch-check-intermediate-buffers = true;
            flycheck-display-errors-delay = "0.25";
          };
        };

        flycheck-posframe = lib.mkIf ide.hoverDoc {
          enable = true;
          hook = ["(flycheck-mode . flycheck-posframe-mode)"];
        };

        flycheck-eglot = lib.mkIf ide.eglot.preset {
          enable = true;
          after = ["flycheck" "eglot"];
          config = "(global-flycheck-eglot-mode)";
        };

        eglot.custom.eglot-stay-out-of = lib.mkIf ide.eglot.preset (lib.mkDefault "'(flymake)");
      };
    };
  };
}
