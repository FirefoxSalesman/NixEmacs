{ lib, ... }:

{
  imports = [
    ./flymake.nix
    ./flycheck.nix
  ];

  options.programs.emacs.init.ide = {
    flymake.enable = lib.mkEnableOption "Enables flymake for any languages that benefit from it.";
    flycheck.enable = lib.mkEnableOption "Enables flycheck for any languages that benefit from it.";
  };
}
