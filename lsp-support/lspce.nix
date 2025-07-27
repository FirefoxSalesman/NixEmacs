{ config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.lspce.preset =
    lib.mkEnableOption "Enable lspce's preset configuration";

  config = lib.mkIf ide.lspce.preset {
    programs.emacs.init.usePackage = {
      lspce = {
        enable = true;
        defer = true;
      };

      eldoc-box = lib.mkIf ide.hoverDoc {
        enable = true;
        hook = [ "(lspce-mode . eldoc-box-hover-at-point-mode)" ];
      };

      breadcrumb = lib.mkIf ide.breadcrumb {
        enable = true;
        hook = [ "(lspce-mode . breadcrumb-local-mode)" ];
      };
    };
  };
}
