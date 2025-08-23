{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.ledger.enable = lib.mkEnableOption "Enables support for ledger.";
  config.programs.emacs.init.usePackage.ledger = lib.mkIf ide.languages.ledger.enable {
    enable = true;
    package = epkgs: epkgs.ledger-mode;
    extraPackages = [pkgs.ledger];
    mode = [''("\\.ledger\\'" . ledger-mode)''];
  };
}
