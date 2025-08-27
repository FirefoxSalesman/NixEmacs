{ pkgs, config, lib, ... }:

{
  options.programs.emacs.init.ide.projectile = lib.mkEnableOption "Enables projectile support";

  config.programs.emacs.init.usePackage = lib.mkIf config.programs.emacs.init.ide.projectile {
    projectile = {
      enable = true;
      custom = {
        projectile-per-project-compilation-buffer = lib.mkDefault true;
        projectile-auto-discover = lib.mkDefault true;
      };
      extraPackages = [pkgs.fd];
      config = "(projectile-mode)";
      bind."C-c p" = "projectile-commander";
    };

    ripgrep = {
      enable = true;
      extraPackages = [pkgs.ripgrep];
    };
  };
}
