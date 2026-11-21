{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.dape.enable = lib.mkEnableOption "Enables dape for debugging";

  config.programs.emacs.init.usePackage = lib.mkIf ide.dape.enable {
    dape = {
      enable = true;
      nhook = [
        {
          names = [ "dape-on-stopped" ];
          actions = [ "(lambda () (dape-info) (dape-repl))" ];
        }
      ];
      bindKeyMap."C-x C-a" = "dape-global-map";
    };

    projection-dape = lib.mkIf ide.project {
      enable = true;
      generalOne.project-prefix-map."d" = "'projection-dape";
    };
  };
}
