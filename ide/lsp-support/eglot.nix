{
  pkgs,
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.eglot.preset =
    lib.mkEnableOption "Enable eglot's preset configuration";

  config = lib.mkIf ide.eglot.preset {
    programs.emacs.init.usePackage = {
      eglot = {
        enable = true;
        defer = true;
        generalTwoConfig.local-leader.eglot-mode-map =
          lib.mkIf config.programs.emacs.init.keybinds.leader-key.enable
            {
              "f" = lib.mkDefault "'eglot-format-buffer";
              "a" = lib.mkDefault "'eglot-code-actions";
              "d" = lib.mkDefault "'eldoc-doc-buffer";
              "r" = lib.mkDefault "'eglot-rename";
            };
        setopt = {
          eglot-report-progress = false;
          eglot-autoshutdown = true;
          #borrowed from doom
          eglot-sync-connect = 1;
        };
      };

      eglot-booster = {
        enable = true;
        extraPackages = [ pkgs.emacs-lsp-booster ];
        after = [ "eglot" ];
        config = "(eglot-booster-mode)";
      };

      eglot-x = {
        enable = true;
        after = [ "eglot" ];
        config = "(eglot-x-setup)";
      };

      eldoc-box = {
        enable = ide.hoverDoc;
        hook = [ "(eglot-managed-mode . eldoc-box-hover-at-point-mode)" ];
      };

      breadcrumb = lib.mkIf ide.breadcrumb {
        enable = true;
        hook = [ "(eglot-managed-mode . breadcrumb-local-mode)" ];
      };

      consult-eglot = lib.mkIf config.programs.emacs.init.completions.smallExtras.enable {
        enable = true;
        after = [ "eglot" ];
        bindLocal.eglot-mode-map."C-M-." = "consult-eglot-symbols";
      };
    };
  };
}
