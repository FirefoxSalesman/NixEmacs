{
  pkgs,
  lib,
  config,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.zig.enable = lib.mkEnableOption "enables zig support";

  config.programs.emacs.init = {
    ide = {
      treesitter.wantTreesitter = true;
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "zig-ts-mode" ];
    };
    usePackage.zig-mode = lib.mkIf ide.languages.zig.enable {
      enable = true;
      extraPackages =
        if ide.eglot.enable || ide.lsp.enable || ide.lspce.enable || ide.lsp-bridge.enable then
          [
            pkgs.zls
            pkgs.zig
          ]
        else
          [ ];
      mode = [ ''"\\.zig\\'"'' ];
      symex = ide.symex;
      lsp = ide.lsp.enable;
      eglot = ide.eglot.enable;
      lspce = lib.mkIf ide.lspce.enable ''"zig" "zls"'';
    };
  };
}
