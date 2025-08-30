{ lib, config, ... }:

let
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.keybinds.leader-key = {
    enable = lib.mkEnableOption "Enables the leader key.";
    globalPrefix = lib.mkOption {
      type = lib.types.string;
      default = "C";
      description = "The prefix key for nix-emacs/global-leader";
    };
    localPrefix = lib.mkOption {
      type = lib.types.string;
      default = "M";
      description = "The prefix key for nix-emacs/local-leader";
    };
  };

  config.programs.emacs.init = lib.mkIf keybinds.leader-key.enable {
    prelude = ''
      (general-create-definer global-leader
        :keymaps 'override
        :states '(emacs ${
          if keybinds.evil.enable then "insert normal hybrid motion visual operator" else ""
        })
        :prefix "SPC"
        :global-prefix "${keybinds.leader-key.globalPrefix}-SPC")
        
      (general-create-definer local-leader
        :prefix "${keybinds.leader-key.localPrefix}-SPC"
        :states '(emacs ${
          if keybinds.evil.enable then "insert normal hybrid motion visual operator" else ""
        }))

    '';

    usePackage = {
      emacs = {
        enable = true;
        generalOne = {
          global-leader = {
            "f" = lib.mkDefault "'find-file";
            "h" = lib.mkDefault "help-map";
          };
          help-map = {
            "F" = lib.mkDefault "'describe-face";
            "C-m" = lib.mkDefault "'describe-keymap";
          };
        };
      };
    };
  };
}
