{
  config,
  lib,
  ...
}:

let
  tools = config.programs.emacs.init.tools;
in
{
  options.programs.emacs.init.tools.sensibleDefaults.enable =
    lib.mkEnableOption "Enables some sensible default settings. Much of this is borrowed from Prot & Emacs from Scratch.";

  config.programs.emacs.init = lib.mkIf tools.sensibleDefaults.enable {
    hasOn = true;
    earlyInit = ''
      (setq use-package-enable-imenu-support t
            make-backup-files nil
            enable-recursive-minibuffers t
            use-short-answers t
            switch-to-buffer-obey-display-actions t
            user-emacs-directory "~/.cache/emacs")
    '';
    usePackage = {
      simple = {
        enable = true;
        setopt = {
          read-extended-command-predicate = lib.mkDefault "'command-completion-default-include-p";
          save-interprogram-paste-before-kill = lib.mkDefault true;
        };
      };

      super-save = {
        enable = true;
        hook = [ "(on-first-file . super-save-mode)" ];
        setopt = {
          super-save-auto-save-when-idle = lib.mkDefault true;
          auto-save-default = lib.mkDefault false;
          super-save-silent = lib.mkDefault true;
          super-save-delete-trailing-whitespace = lib.mkDefault true;
        };
      };
    };
  };
}
