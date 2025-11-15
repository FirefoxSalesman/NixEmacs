{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.dape.enable = lib.mkEnableOption "Enables dape for debugging";

  config.programs.emacs.init.usePackage = lib.mkIf ide.dape.enable {
    dape = {
      enable = true;
      # after = ["eglot"];
      hook = ["(dape-on-stopped . (lambda () (dape-info) (dape-repl)))"];
      bindKeyMap."C-x C-a" = "dape-global-map";
      # setopt.dape-key-prefix = ''"\C-x\C-a"'';
    };

    projection-dape = lib.mkIf ide.project {
      enable = true;
      generalOne.project-prefix-map."d" = "'projection-dape";
    };
  };
}
