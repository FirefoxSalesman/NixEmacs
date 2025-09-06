{ pkgs, config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.nix.enable =
    lib.mkEnableOption "enables nix support (highly reccommended)";

  config = lib.mkIf ide.languages.nix.enable {
    programs.emacs.init.usePackage = {
      nix-mode = {
        enable = true;
        mode = [ ''"\\.nix\\'"'' ];
        extraPackages = if ide.lsp-bridge.enable || ide.lspce.enable
        || ide.lsp.enable || ide.eglot.enable then
          with pkgs; [ nixd nixfmt ]
        else
          [ ];
        eglot = ide.eglot.enable;
        lsp = ide.lsp.enable;
        lspce = ide.lspce.enable;
        symex = ide.symex;
        config = lib.mkIf ide.lspce.enable ''(nix-emacs-lspce-add-server-program '("nix") "nixd")'';
      };

      json-ts-mode = {
        enable = true;
        # stolen from doom
        mode = [ ''"/flake\\.lock\\'"'' ];
      };

      lsp-bridge.custom.lsp-bridge-nix-lsp-server =
        lib.mkIf ide.lsp-bridge.enable ''"nixd"'';

      ob-nix = lib.mkIf ide.languages.org.enable {
        enable = true;
        babel = lib.mkIf ide.languages.org.enable "nix";
      };
    };
  };
}
