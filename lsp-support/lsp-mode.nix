{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.lsp.preset = lib.mkEnableOption "Enable lsp-mode's preset configuration (borrowed from doom)";

  config = lib.mkIf ide.lsp.preset {
    programs.emacs.init.usePackage = {
      # We elect not to use lsp-booster, because I have no idea how to compile lsp-mode with plists support
      lsp-mode = {
        enable = true;
        defer = true;
        custom = {
          lsp-enable-folding = lib.mkDefault false;
          lsp-enable-text-document-color = lib.mkDefault false;
          lsp-enable-on-type-formatting = lib.mkDefault false;
          lsp-headerline-breadcrumb-enable = lib.mkDefault ide.breadcrumb;
        };
      };

      lsp-ui = lib.mkIf ide.hoverDoc {
        enable = true;
        hook = ["(lsp-mode . lsp-ui-mode)"];
        custom = {
          lsp-ui-doc-show-with-mouse = lib.mkDefault false;
          lsp-ui-doc-position = lib.mkDefault "'at-point";
          lsp-ui-doc-show-with-cursor = lib.mkDefault true;
          lsp-ui-sideline-ignore-duplicate = lib.mkDefault true;
          lsp-ui-sideline-show-hover = lib.mkDefault false;
          lsp-ui-sideline-actions-icon = lib.mkDefault "lsp-ui-sideline-actions-icon-default";
        };
      };
    };
  };
}
