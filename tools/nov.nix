{ pkgs, config, lib, ... }:

{
  options.programs.emacs.init.tools.nov = lib.mkEnableOption "Enables nov.el, for reading epubs";

  config.programs.emacs.init.usePackage.nov = lib.mkIf config.programs.emacs.init.tools.nov {
    enable = true;
    extraPackages = [pkgs.unzip];
    mode = [''("\\.epub\\'" . nov-mode)''];
  };
}
