{ lib, config, ... }:

let
  keybinds = config.programs.emacs.init.keybinds;
  evilStates = if keybinds.evil.enable then "insert normal hybrid motion visual operator" else "";
  symex = if config.programs.emacs.init.ide.symex then "symex" else "";
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
        :states '(emacs ${evilStates} ${symex})
        :prefix "SPC"
        :global-prefix "${keybinds.leader-key.globalPrefix}-SPC")
        
      (general-create-definer local-leader
        :prefix "${keybinds.leader-key.localPrefix}-SPC"
        :states '(emacs ${evilStates} ${symex}))

    '';

    usePackage = {
      emacs = {
        enable = true;
        generalOne = {
          global-leader = {
            "f" = lib.mkIf (!config.programs.emacs.init.completions.ivy.enable) (lib.mkDefault "'find-file");
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
