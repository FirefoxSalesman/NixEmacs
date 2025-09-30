{
  lib,
  config,
  ...
}:

let
  completions = config.programs.emacs.init.completions;
  keybinds = config.programs.emacs.init.keybinds;
in
{
  options.programs.emacs.init.completions.vertico.enable =
    lib.mkEnableOption "Enables vertico as a completion system. Many things are borrowed from Doom";

  config.programs.emacs.init = lib.mkIf completions.vertico.enable {
    hasOn = true;
    usePackage = {
      vertico = {
        enable = true;
        hook = [ "(on-first-input . vertico-mode)" ];
        custom.vertico-cycle = true;
        generalTwo.":n".vertico-map = lib.mkIf keybinds.evil.enable {
          "RET" = "'vertico-exit";
          "${keybinds.evil.keys.down}" = "'vertico-next";
          "${keybinds.evil.keys.up}" = "'vertico-previous";
        };
      };

      vertico-quick = lib.mkIf keybinds.avy.enable {
        enable = true;
        generalTwo.":n".vertico-map = lib.mkIf keybinds.evil.enable {
          "${keybinds.avy.evilModifierKey}-${keybinds.evil.keys.down}" = "'vertico-quick-jump";
          "${keybinds.avy.evilModifierKey}-${keybinds.evil.keys.up}" = "'vertico-quick-jump";
        };
        bindLocal.vertico-map."M-g f" = lib.mkIf (!keybinds.evil.enable) "vertico-quick-jump";
      };

      vertico-prescient = lib.mkIf completions.prescient {
        enable = true;
        hook = [ "(minibuffer-mode . vertico-prescient-mode)" ];
        custom = {
          vertico-prescient-enable-filtering = false;
          vertico-prescient-completion-styles = lib.mkDefault (
            if completions.orderless then "'(orderless prescient basic)" else "'(prescient basic)"
          );
          vertico-prescient-enable-sorting = true;
        };
      };

    };
  };
}
