{
  pkgs,
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
  matches = p: lib.match p ide.languages.python.languageServer != null;
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.ide.languages.python = {
    enable = lib.mkEnableOption "Enables python support. Partly borrowed from snakemacs.";
    jupyter = lib.mkEnableOption "enables code-cells, a minor mode for editing jupyter files. If org support is enabled, jupyter kernels can be calledfrom org-babel";
    snakemake = lib.mkEnableOption "enables snakemake support";
    languageServer = lib.mkOption {
      type = lib.types.enum [
        "ty"
        "basedpyright"
        "zuban"
        "pyrefly"
      ];
      default = "ty";
      description = "the language server to use with python. Can be any of ty, basedpyright, zuban, or pyrefly.";
    };
    wantRuff = lib.mkEnableOption "Enables ruff in addition to the other language servers.";
  };

  config.programs.emacs.init = lib.mkIf ide.languages.python.enable {
    ide = {
      treesitter.wantTreesitter = true;
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "python-ts-mode" ];
    };

    tools.apheleia.modeFormatters.python-ts-mode = lib.mkIf (
      ide.eglot.enable && config.programs.emacs.init.tools.apheleia.enable
    ) (lib.mkDefault "eglot");

    usePackage = {
      python-ts-mode = {
        enable = true;
        babel = lib.mkIf ide.languages.org.enable "python";
        eglot = ide.eglot.enable;
        symex = ide.symex;
        lsp = ide.lsp.enable;
        mode = [ ''"\\.py\\'"'' ];
        extraPackages =
          (
            if ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable then
              if (matches "basedpyright") then
                [ pkgs.basedpyright ]
              else if (matches "zuban") then
                [ pkgs.zuban ]
              else if (matches "pyrefly") then
                [ pkgs.pyrefly ]
              else if (matches "ty") then
                [ pkgs.ty ]
              else
                [ ]
            else
              [ ]
          )
          ++ (if (ide.dap.enable || ide.dape.enable) then [ pkgs.python313Packages.debugpy ] else [ ])
          ++ (
            if ide.languages.python.wantRuff then
              [ pkgs.ruff ] ++ (if (ide.eglot.enable || ide.lspce.enable) then [ pkgs.rassumfrassum ] else [ ])
            else
              [ ]
          );
        # https://gregnewman.io/blog/emacs-take-two/
        lspce = lib.mkIf ide.lspce.enable ''
                    "python" ${if ide.languages.python.wantRuff then ''"rass" "--" '' else ""} ${
                      if matches "basedpyright" then
                        ''"basedpyright-langserver" "--stdio"''
                      else if matches "zuban" then
                        ''"zubanls"''
                      else if matches "pyrefly" then
                        ''"pyrefly" "lsp"''
                      else
                        ''"ty server"''
                    }
          	  ${if ide.languages.python.wantRuff then ''"--" "ruff" "server"'' else ""}
        '';
        generalTwoConfig."local-leader".python-mode-map."r" = lib.mkIf keybinds.leader-key.enable (
          lib.mkDefault "'python-shell-send-buffer"
        );
        config = lib.mkIf ide.dap.enable "(require 'dap-python)";
        setopt.dap-python-debugger = lib.mkIf ide.dap.enable (lib.mkDefault "'debugpy");
      };

      eglot-python-preset = lib.mkIf ide.eglot.enable {
        enable = true;
        extraPackages = [ pkgs.uv ];
        setopt = {
          eglot-python-preset-lsp-server = lib.mkDefault (
            if ide.languages.python.wantRuff then "'rass" else "'${ide.languages.python.languageServer}"
          );
          eglot-python-preset-rass-tools = lib.mkIf ide.languages.python.wantRuff (
            lib.mkDefault [
              "'${ide.languages.python.languageServer}"
              "'ruff"
            ]
          );
        };
      };

      lsp-pyright = lib.mkIf ((matches "basedpyright") && ide.lsp.enable) {
        enable = true;
        after = [ "lsp-mode" ];
        setopt.lsp-pyright-langserver-command = ''"basedpyright"'';
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
