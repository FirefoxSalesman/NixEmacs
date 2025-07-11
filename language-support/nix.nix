{ pkgs, config, lib, ... } :

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.nix.enable = lib.mkEnableOption "enables nix support (highly reccommended)";

  config = lib.mkIf ide.languages.nix.enable {
    programs.emacs.init.usePackage = {
      nix-mode = {
        enable = true;
        mode = [''"\\.nix\\'"''];
        extraPackages = if ide.lsp.enable || ide.eglot.enable then with pkgs; [nixd nixfmt] else [];
        eglot = ide.eglot.enable;
        lsp = ide.lsp.enable;
        symex = ide.symex;
      };

      json-ts-mode = {
        enable = true;
        # stolen from doom
        mode = [''"/flake\\.lock\\'"''];
      };
    };
  };
}
