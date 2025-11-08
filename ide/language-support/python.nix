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
    jupyter = lib.mkEnableOption "enables code-cells, a minor mode for editing jupyter files. If org support is enabled, jupyter kernels can be calledfrom org-babel";
    snakemake = lib.mkEnableOption "enables snakemake support";
    languageServer = lib.mkOption {
      type = lib.types.str;
      default = "basedpyright";
      description = "the language server to use with python. Can be any of basedpyright, pylsp, pyright, or jedi";
    };
  };

  config.programs.emacs.init = lib.mkIf ide.languages.python.enable {
    ide = {
      treesitter.wantTreesitter = true;
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "python-ts-mode" ];
    };
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
        hook = [ "(python-ts-mode . pet-mode)" ];
      };

      snakemake-mode = lib.mkIf ide.languages.python.snakemake {
        enable = true;
        mode = [ ''"Snakefile\\'"'' ];
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

      # Entirely stolen from snakemacs. The free functions are much appreciated
      jupyter = lib.mkIf (ide.languages.python.jupyter && ide.languages.org.enable) {
        enable = true;
        after = [ "org" ];
        babel = "jupyter";
        extraPackages = [ pkgs.jupyter ];
        hook = [ "(org-after-execute . org-redisplay-inline-images)" ];
        preface = ''
          (defun nix-emacs/jupyter-refresh-kernelspecs ()
                 "Refresh Jupyter kernelspecs"
                 (interactive)
                 (jupyter-available-kernelspecs t))

          (defun nix-emacs/jupyter-refesh-langs ()
                 "Refresh Jupyter languages"
                 (interactive)
                 (org-babel-jupyter-aliases-from-kernelspecs t))
          (defvar nix-emacs/jupyter-runtime-folder (expand-file-name "~/.local/share/jupyter/runtime"))
          (defun nix-emacs/get-open-ports ()
                 (mapcar #'string-to-number
                         (split-string (shell-command-to-string
                                        "ss -tulpnH | awk '{print $5}' | sed -e 's/.*://'")
                                        "\n")))
          (defun nix-emacs/list-jupyter-kernel-files ()
                 (mapcar
                  (lambda (file)
                          (cons
                           (car file)
                           (cdr (assq 'shell_port (json-read-file (car file))))))
                  (sort (directory-files-and-attributes nix-emacs/jupyter-runtime-folder
                                         t ".*kernel.*json$")
                        (lambda (x y) (not (time-less-p (nth 6 x) (nth 6 y)))))))
          (defun nix-emacs/select-jupyter-kernel ()
                 (let ((ports (nix-emacs/get-open-ports))
                       (files (nix-emacs/list-jupyter-kernel-files)))
                      (completing-read "Jupyter kernels: "
                        (seq-filter (lambda (file) (member (cdr file) ports)) files))))
          (defun nix-emacs/insert-jupyter-kernel ()
                 "Insert a path to an active Jupyter kernel into the buffer"
                 (interactive)
                 (insert (nix-emacs/select-jupyter-kernel)))
          (defun nix-emacs/jupyter-connect-repl ()
                 "Open an emacs-jupyter REPL, connected to a Jupyter kernel"
                 (interactive)
                 (jupyter-connect-repl (nix-emacs/select-jupyter-kernel) nil nil nil t))
          (defun nix-emacs/jupyter-cleanup-kernels ()
                 (interactive)
                 (let* ((ports (nix-emacs/get-open-ports))
                        (files (nix-emacs/list-jupyter-kernel-files))
                        (to-delete
                         (seq-filter
                          (lambda (file) (not (member (cdr file) ports))) files)))
                       (when (and (length> to-delete 0)
                                  (y-or-n-p
                                   (format "Delete %d files?" (length to-delete))))
                             (dolist (file to-delete)
                                     (delete-file (car file))))))
        '';
      };
    };
  };
}
