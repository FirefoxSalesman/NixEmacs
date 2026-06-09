{
  config,
  lib,
  ...
}:

let
  ai = config.programs.emacs.init.ai;
  keybinds = config.programs.emacs.init.keybinds;
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ai.gptel = {
    enable = lib.mkEnableOption "Enables gptel. Config borrowed from doom. It is strongly reccomended that you read gptel's readme before using this.";
  };

  config.programs.emacs.init.usePackage = lib.mkIf ai.gptel.enable {
    gptel = {
      enable = true;
      setopt.gptel-default-mode = lib.mkDefault "'org-mode";
      generalOne.global-leader = lib.mkIf keybinds.leader-key.enable {
        "g" = lib.mkDefault '''(:ignore t :which-key "gptel")'';
        "gp" = lib.mkDefault '''("prompt" . gptel)'';
        "gt" = lib.mkDefault '''("add text to context" . gptel-add)'';
        "gf" = lib.mkDefault '''("add file to context" . gptel-add-file)'';
        "gm" = lib.mkDefault '''("open configuration menu" . gptel-menu)'';
        "gr" = lib.mkDefault '''("rewrite current region" . gptel-rewrite)'';
      };
    };

    gptel-org = lib.mkIf ide.languages.org.enable {
      enable = true;
      package = epkgs: epkgs.gptel;
      command = [
        "gptel-org-set-topic"
        "gptel-org-set-properties"
      ];
      generalOne.global-leader = lib.mkIf keybinds.leader-key.enable {
        "go" = lib.mkDefault '''("limit context to current org heading" . gptel-org-set-topic)'';
        "gO" = lib.mkDefault '''("store gptel config as org properties" . gptel-org-set-properties)'';
      };
    };

    ob-gptel = lib.mkIf ide.languages.org.enable {
      enable = true;
      config = ''
        (defun ob-gptel-setup-completions ()
              (add-hook 'completion-at-point-functions
                'ob-gptel-capf nil t))
      '';
      hook = [ "(org-mode . ob-gptel-setup-completions)" ];
      babel = "gptel";
    };

    gptel-magit = lib.mkIf ide.magit.enable {
      enable = true;
      after = [ "magit" ];
      ghookf = [ "('magit-mode 'gptel-magit-install)" ];
    };

    gptel-quick = {
      enable = true;
      generalOne.global-leader."ge" = lib.mkIf keybinds.leader-key.enable (
        lib.mkDefault '''("Explain the current region" . gptel-quick)''
      );
    };
  };
}
