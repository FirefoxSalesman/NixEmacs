{ pkgs, lib, config, ... }:

let
  completions = config.programs.emacs.init.completions;
in
{
    options.programs.emacs.init.completions.orderless = lib.mkEnableOption "Enables orderless completion styles. Borrowed from David Wilson's config";
    
    # Borrowed from David Wilson
    config.programs.emacs.init = lib.mkIf completions.orderless {
      hasOn = true;
      usePackage.orderless = {
        enable = true;
        custom = {
          completion-styles = lib.mkDefault (if completions.prescient then "'(orderless prescient basic)" else "'(orderless basic)");
          completion-category-defaults = lib.mkDefault false;
          completion-category-overrides = lib.mkDefault "'((file (styles . (partial-completion))))";
        };
        afterCall = ["on-first-input-hook"];
      };
    };
}
