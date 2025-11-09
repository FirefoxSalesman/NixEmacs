{
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.copilot = {
    enable = lib.mkEnableOption "Enable Copilot completions";
    keepOutOf = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Major modes Copilot shouldn't be enabled in.";
    };
  };

  config.programs.emacs.init.usePackage.copilot = lib.mkIf ide.copilot.enable {
    enable = true;
    hook = [
      ''
        (prog-mode . (lambda ()
        	                     (when (length= (-filter 'major-mode? '(${
                                lib.concatMapStrings (k: "${k} ") ide.copilot.keepOutOf
                              })) 0)
        	                       (copilot-mode))))
      ''
    ];
    preface = ''
      (defun nix-emacs/kill-copilot ()
        "Kill copilot process & related buffers."
        (interactive)  
        (jsonrpc-shutdown copilot--connection)
        (dolist (buf '("*copilot-language-server-log*" "*copilot events*"))
          (when (get-buffer buf)
            (kill-buffer buf))))
    '';
    config = ''
            (add-hook 'kill-buffer-hook
                      (lambda ()
                              (when (and (not (or (equal "*copilot-language-server-log*" (buffer-name))
                                                  (equal "*copilot events*" (buffer-name))))
                                         (length= (-filter (lambda (x)
                                                                   (with-current-buffer x
                                                                                        (not (or (eq (derived-mode-p 'prog-mode) nil)
      										                 ${lib.concatMapStrings (k: "(major-mode? ${k})\n") ide.copilot.keepOutOf}
                                                                                                 (s-contains? "org-src-fontification" (buffer-name))))))
            			                           (buffer-list))
            		                          0))
            	                    (nix-emacs/kill-copilot))))
    '';
    bindLocal.copilot-completion-map = {
      "TAB" = lib.mkDefault "copilot-accept-completion";
      "<tab>" = lib.mkDefault "copilot-accept-completion";
      "C-i" = lib.mkDefault "copilot-accept-completion";
    };
  };
}
