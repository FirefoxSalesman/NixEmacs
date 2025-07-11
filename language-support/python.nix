{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
  matches = p: n: lib.match p n != null;
in
{
  options.programs.emacs.init.ide.languages.python = {
    enable = lib.mkEnableOption "enables python support";
    jupyter = lib.mkEnableOption "enables code-cells, a minor mode for editing jupyter files";
    languageServer = lib.mkOption {
      type = lib.types.str;
      default = "basedpyright";
      description = "the language server to use with python. Can be any of basedpyright, pylsp, pyright, or jedi";
    };
  };

  config = lib.mkIf ide.languages.python.enable {
    programs.emacs.init.usePackage = {
      python-ts-mode = {
        enable = true;
        eglot = ide.eglot.enable;
        symex = ide.symex;
        lsp = ide.lsp.enable;
        mode = [''"\\.py\\'"''];
        extraPackages = if ide.lsp.enable || ide.eglot.enable then
          if (matches "basedpyright" ide.languages.python.languageServer) then with pkgs; [ basedpyright ruff ] else
            if (matches "pylsp" ide.languages.python.languageServer) then [pkgs.python313Packages.python-lsp-server] else
              if (matches "pyright" ide.languages.python.languageServer) then [pkgs.pyright] else
                if (matches "jedi" ide.languages.python.languageServer) then [pkgs.python313Packages.jedi-language-server] else []
                        else [];
        config = "${if matches "basedpyright" ide.languages.python.languageServer then ''
          (add-to-list 'eglot-server-programs '(python-ts-mode . ("basedpyright-langserver" "--stdio" 
                                                                   :initializationOptions (:basedpyright (:plugins (
                                                                   :ruff (:enabled t
                                                                          :lineLength 88
                                                                          :exclude ["E501"]  ; Disable line length warnings
                                                                          :select ["E", "F", "I", "UP"])  ; Enable specific rule families
                                                                   :pycodestyle (:enabled nil)  ; Disable other linters since we're using ruff
                                                                   :pyflakes (:enabled nil)
                                                                   :pylint (:enabled nil)
                                                                   :rope_completion (:enabled t)
                                                                   :autopep8 (:enabled nil)))))))
        
          '' else ""}";
      };

      code-cells = {
        enable = ide.languages.python.jupyter;
        demand = lib.mkDefault true;
        extraPackages = with pkgs; [python313Packages.jupytext];
      };
    };
  };
}
