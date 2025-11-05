{
  pkgs,
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
  matches = p: n: lib.match p n != null;
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.ide.languages.python = {
    enable = lib.mkEnableOption "Enables python support. Partly borrowed from snakemacs.";
    jupyter = lib.mkEnableOption "enables code-cells, a minor mode for editing jupyter files";
    snakemake = lib.mkEnableOption "enables snakemake support";
    languageServer = lib.mkOption {
      type = lib.types.str;
      default = "basedpyright";
      description = "the language server to use with python. Can be any of basedpyright, pylsp, pyright, or jedi";
    };
  };

  config.programs.emacs.init = lib.mkIf ide.languages.python.enable {
    ide.treesitter.wantTreesitter = true;
    usePackage = {
      python-ts-mode = {
        enable = true;
        babel = lib.mkIf ide.languages.org.enable "python";
        eglot = lib.mkIf ide.eglot.enable ''
          ("basedpyright-langserver" "--stdio" 
                                     :initializationOptions (:basedpyright (:plugins (
                                     :ruff (:enabled t
                                            :lineLength 88
                                            :exclude ["E501"]  ; Disable line length warnings
                                            :select ["E", "F", "I", "UP"])  ; Enable specific rule families
                                     :pycodestyle (:enabled nil)  ; Disable other linters since we're using ruff
                                     :pyflakes (:enabled nil)
                                     :pylint (:enabled nil)
                                     :rope_completion (:enabled t)
                                     :autopep8 (:enabled nil)))))'';
        symex = ide.symex;
        lsp = ide.lsp.enable;
        mode = [ ''"\\.py\\'"'' ];
        extraPackages =
          if ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable then
            if (matches "basedpyright" ide.languages.python.languageServer) then
              with pkgs;
              [
                basedpyright
                ruff
              ]
            else if (matches "pylsp" ide.languages.python.languageServer) then
              [ pkgs.python313Packages.python-lsp-server ]
            else if (matches "pyright" ide.languages.python.languageServer) then
              [ pkgs.pyright ]
            else if (matches "jedi" ide.languages.python.languageServer) then
              [ pkgs.python313Packages.jedi-language-server ]
            else
              [ ]
          else
            [ ];
        # https://gregnewman.io/blog/emacs-take-two/
        lspce = lib.mkIf ide.lspce.enable ''
          "python" ${
            if matches "basedpyright" ide.languages.python.languageServer then
              ''"basedpyright-langserver" "--stdio"''
            else if matches "pyright" ide.languages.python.languageServer then
              ''"pyright-langserver" "--stdio"''
            else if matches "pylsp" ide.languages.python.languageServer then
              ''"pylsp"''
            else
              ''"jedi-language-server"''
          }
        '';
        generalTwoConfig."local-leader".python-mode-map."r" = lib.mkIf keybinds.leader-key.enable (
          lib.mkDefault "'python-shell-send-buffer"
        );
      };

      lsp-pyright =
        lib.mkIf
          (
            (
              (matches "basedpyright" ide.languages.python.languageServer)
              || (matches "pyright" ide.languages.python.languageServer)
            )
            && ide.lsp.enable
          )
          {
            enable = true;
            after = [ "lsp-mode" ];
            setopt.lsp-pyright-langserver-command =
              if (matches "basedpyright" ide.languages.python.languageServer) then
                ''"basedpyright"''
              else
                ''"pyright"'';
          };

      lsp-bridge.setopt.lsp-bridge-python-lsp-server = lib.mkIf ide.lsp-bridge.enable "${ide.languages.python.languageServer
      }";

      python-docstring = {
        enable = true;
        hook = [ "(python-ts-mode . python-docstring-mode)" ];
      };

      pet = {
        enable = true;
        after = [ "python-ts-mode" ];
        config = "(add-hook 'python-base-mode-hook 'pet-mode -10)";
      };

      code-cells = lib.mkIf ide.languages.python.jupyter {
        enable = true;
        demand = lib.mkDefault true;
        extraPackages = with pkgs; [ python313Packages.jupytext ];
        generalTwoConfig = {
          "local-leader".code-cells-mode-map."e" = lib.mkIf keybinds.leader-key.enable (
            lib.mkDefault "'code-cells-eval"
          );
          ":n".code-cells-mode-map = lib.mkIf keybinds.evil.enable {
            "M-${keybinds.evil.keys.down}" = "'code-cells-forward-cell";
            "M-${keybinds.evil.keys.up}" = "'code-cells-backward-cell";
          };
        };
      };
    };
  };
}
