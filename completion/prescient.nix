{ config, lib, ... }:

{
  options.programs.emacs.init.completions.prescient = lib.mkEnableOption "Enables prescient sorting where possible";

  config.programs.emacs.init = lib.mkIf config.programs.emacs.init.completions.prescient {
    hasOn = true;
    usePackage.prescient = {
      enable = true;
      defer = true;
      config = "(prescient-persist-mode)";
      custom.prescient-history-length = "100";
      afterCall = ["on-first-input-hook"];
    };
  };
}
