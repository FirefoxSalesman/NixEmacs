{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.toml.enable = lib.mkEnableOption "enables toml support";

  config = lib.mkIf ide.languages.toml.enable {
    programs.emacs.init.usePackage.toml-ts-mode = {
      enable = true;
      mode = [''"\\.toml\\'"''];
      symex = ide.symex;
    };
  };
}
