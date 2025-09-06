{
  pkgs,
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.ledger.enable =
    lib.mkEnableOption "Enables support for ledger.";
  config.programs.emacs.init.usePackage = lib.mkIf ide.languages.ledger.enable {
    ledger = {
      enable = true;
      package = epkgs: epkgs.ledger-mode;
      extraPackages = [ pkgs.ledger ];
      mode = [ ''("\\.ledger\\'" . ledger-mode)'' ];
    };

    company-ledger = lib.mkIf config.programs.emacs.init.completions.company.enable {
      enable = true;
      after = [ "company" ];
      config = "(add-to-list 'company-backends 'company-ledger)";
    };
  };
}
