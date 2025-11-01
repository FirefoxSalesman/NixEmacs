{
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
  completions = config.programs.emacs.init.completions;
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.ide.lsp.preset =
    lib.mkEnableOption "Enable lsp-mode's preset configuration (borrowed from doom)";

  config = lib.mkIf ide.lsp.preset {
    programs.emacs.init.usePackage = {
      # We elect not to use lsp-booster, because I have no idea how to compile lsp-mode with plists support
      lsp-mode = {
        enable = true;
        defer = true;
        setopt = {
          lsp-enable-folding = lib.mkDefault false;
          lsp-enable-text-document-color = lib.mkDefault false;
          lsp-enable-on-type-formatting = lib.mkDefault false;
          lsp-headerline-breadcrumb-enable = lib.mkDefault ide.breadcrumb;
        };
        generalTwoConfig.local-leader.lsp-mode-map = lib.mkIf keybinds.leader-keys.enable {
          "f" = "'lsp-format-buffer";
          "a" = "'lsp-execute-code-action";
          "r" = "'lsp-rename";
        };
        generalOneConfig.lsp-ui-peek-mode-map = lib.mkIf keybinds.evil.enable {
          "${keybinds.evil.keys.down}" = "'lsp-ui-peek--select-next";
          "${keybinds.evil.keys.up}" = "'lsp-ui-peek--select-prev";
          "C-${keybinds.evil.keys.down}" = "'lsp-ui-peek--select-next-file";
          "C-${keybinds.evil.keys.up}" = "'lsp-ui-peek--select-prev-file";
        };
      };

      lsp-ui = lib.mkIf ide.hoverDoc {
        enable = true;
        hook = [ "(lsp-mode . lsp-ui-mode)" ];
        setopt = {
          lsp-ui-doc-show-with-mouse = lib.mkDefault false;
          lsp-ui-doc-position = lib.mkDefault "'at-point";
          lsp-ui-doc-show-with-cursor = lib.mkDefault true;
          lsp-ui-sideline-ignore-duplicate = lib.mkDefault true;
          lsp-ui-sideline-show-hover = lib.mkDefault false;
          lsp-ui-sideline-actions-icon = lib.mkDefault "lsp-ui-sideline-actions-icon-default";
        };
      };

      consult-lsp = lib.mkIf completions.smallExtras.enable {
        enable = true;
        after = [ "lsp-mode" ];
        bindLocal.lsp-mode-map."C-M-." = "consult-lsp-symbols";
      };

      ivy-lsp = lib.mkIf completions.ivy.enable {
        enable = true;
        command = [ "lsp-ivy-global-workspace-symbol" ];
        after = [ "lsp-mode" ];
        bindLocal.lsp-mode-map."C-M-." = "lsp-ivy-workspace-symbol";
      };
    };
  };
}
