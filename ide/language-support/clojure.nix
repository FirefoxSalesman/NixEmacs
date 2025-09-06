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
  options.programs.emacs.init.ide.languages.clojure.enable =
    lib.mkEnableOption "enables clojure support";

  config = lib.mkIf ide.languages.clojure.enable {
    programs.emacs.init.usePackage = {
      clojure-mode = {
        enable = true;
        babel = lib.mkIf ide.languages.org.enable "clojure";
        extraPackages =
          if ide.lsp-bridge.enable || ide.lsp.enable || ide.eglot.enable then
            with pkgs; [ clojure-lsp ]
          else
            [ ];
        mode = [ ''"\\.clj\\'"'' ];
        lsp = ide.lsp.enable;
        eglot = ide.eglot.enable;
        symex = ide.symex;
        config = lib.mkIf ide.lspce.enable ''(nix-emacs-lspce-add-server-program '("clojure" "clojurec" "clojurescript") "clojure-lsp")'';
      };

      cider = {
        enable = ide.languages.java.clojure;
        hook = [ "(clojure-mode . cider-mode)" ];
        generalTwo.local-leader.cider-mode-map."s" = lib.mkIf config.programs.emacs.init.keybinds.leader-key.enable lib.mkDefault '''(cider-jack-in :which-key "start cider")''; 
      };
    };
  };
}
