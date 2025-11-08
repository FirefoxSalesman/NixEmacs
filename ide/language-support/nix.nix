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
  options.programs.emacs.init.ide.languages.nix.enable =
    lib.mkEnableOption "enables nix support (highly reccommended)";

  config = lib.mkIf ide.languages.nix.enable {
    programs.emacs.init = {
      ide = {
        treesitter.treesitterGrammars."nix" = "https://github.com/nix-community/tree-sitter-nix";
        treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "nix-ts-mode" ];
      };
      usePackage = {
        nix-ts-mode = {
          enable = true;
          mode = [ ''"\\.nix\\'"'' ];
          extraPackages =
            if ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable then
              with pkgs;
              [
                nixd
                nixfmt
              ]
            else
              [ ];
          eglot = ide.eglot.enable;
          lsp = ide.lsp.enable;
          symex = ide.symex;
          lspce = lib.mkIf ide.lspce.enable ''"nix" "nixd"'';
        };

        json-ts-mode = {
          enable = true;
          # stolen from doom
          mode = [ ''"/flake\\.lock\\'"'' ];
        };

        lsp-bridge.setopt.lsp-bridge-nix-lsp-server = lib.mkIf ide.lsp-bridge.enable ''"nixd"'';

        ob-nix = lib.mkIf ide.languages.org.enable {
          enable = true;
          babel = lib.mkIf ide.languages.org.enable "nix";
        };
      };
    };
  };
}
