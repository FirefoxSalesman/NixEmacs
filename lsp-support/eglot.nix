{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.eglot.preset = lib.mkEnableOption "Enable eglot's preset configuration";

  config = lib.mkIf ide.eglot.preset {
    programs.emacs.init.usePackage = {
      eglot = {
        enable = true;
        defer = true;
        custom = {
          eglot-report-progress = "nil";
          eglot-autoshutdown = "t";
          #borrowed from doom
          eglot-sync-connect = "1";
        };
      };

      eglot-booster = {
        enable = true;
        extraPackages = [pkgs.emacs-lsp-booster];
        after = ["eglot"];
        config = "(eglot-booster-mode)";
      };

      eglot-x = {
        enable = true;
        after = ["eglot"];
        config = "(eglot-x-setup)";
      };

      eldoc-box = {
        enable = ide.hoverDoc;
        hook = ["(eglot-managed-mode . eldoc-box-hover-at-point-mode)"];
      };

      breadcrumb = lib.mkIf ide.breadcrumb {
        enable = true;
        hook = ["(eglot-managed-mode . breadcrumb-local-mode)"];
      };
    };
  };
}
