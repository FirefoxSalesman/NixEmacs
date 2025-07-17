{ pkgs, config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.clojure.enable =
    lib.mkEnableOption "enables clojure support";

  config = lib.mkIf ide.languages.clojure.enable {
    programs.emacs.init.usePackage = {
      clojure-mode = {
        enable = true;
        extraPackages =
          if ide.lsp-bridge.enable || ide.lsp.enable || ide.eglot.enable then
            with pkgs; [ clojure-lsp ]
          else
            [ ];
        mode = [ ''"\\.clj\\'"'' ];
        lsp = ide.lsp.enable;
        lsp-bridge = ide.lsp-bridge.enable;
        eglot = ide.eglot.enable;
        symex = ide.symex;
        config = lib.mkIf ide.lspce.enable ''
          (with-eval-after-load 'lspce
                                (dolist (mode '("clojure" "clojurec" "clojurescript")))
                                        (add-to-list 'lspce-server-programs (list mode "clojure-lsp" "")))
        '';
      };

      cider = {
        enable = ide.languages.java.clojure;
        hook = [ "(clojure-mode . cider-mode)" ];
      };
    };
  };
}
