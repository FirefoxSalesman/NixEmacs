{ pkgs, lib, config, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.zig.enable = lib.mkEnableOption "enables zig support";

  config = lib.mkIf ide.languages.zig.enable {
    programs.emacs.init.usePackage.zig-mode = {
      enable = true;
      extraPackages = if ide.eglot.enable || ide.lsp.enable || ide.lspce.enable || ide.lsp-bridge.enable then [pkgs.zls pkgs.zig] else [];
      mode = [''"\\.zig\\'"''];
      symex = ide.symex;
      lsp = ide.lsp.enable;
      lspce = ide.lspce.enable;
      eglot = ide.eglot.enable;
      config = lib.mkIf ide.lspce.enable ''
        (with-eval-after-load 'lspce (add-to-list 'lspce-server-programs '("zig" "zls" "")))
      '';
    };
  };
}
