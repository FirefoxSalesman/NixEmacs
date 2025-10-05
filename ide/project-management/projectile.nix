{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.programs.emacs.init.ide.projectile = lib.mkEnableOption "Enables projectile support";

  config.programs.emacs.init.usePackage = lib.mkIf config.programs.emacs.init.ide.projectile {
    projectile = {
      enable = true;
      setopt = {
        projectile-per-project-compilation-buffer = lib.mkDefault true;
        projectile-auto-discover = lib.mkDefault true;
      };
      extraPackages = [ pkgs.fd ];
      config = "(projectile-mode)";
      bind."C-c p" = "projectile-commander";
      generalOne.global-leader."P" = lib.mkIf config.programs.emacs.init.keybinds.leader-key.enable (
        lib.mkDefault "projectile-command-map"
      );
    };

    counsel-projectile = lib.mkIf config.programs.emacs.init.completions.ivy.enable {
      enable = true;
      after = [ "projectile" ];
      config = ''
        (define-key [remap projectile-find-file] #'counsel-projectile-find-file)
        (define-key [remap projectile-find-dir] #'counsel-projectile-find-dir)
        (define-key [remap projectile-switch-to-buffer] #'counsel-projectile-switch-to-buffer)
        (define-key [remap projectile-grep] #'counsel-projectile-grep)
        (define-key [remap projectile-ag] #'counsel-projectile-ag)
        (define-key [remap projectile-switch-project] #'counsel-projectile-switch-project)
      '';
    };

    ripgrep = {
      enable = true;
      extraPackages = [ pkgs.ripgrep ];
    };
  };
}
