{ pkgs, config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.swift.enable = lib.mkEnableOption "Enables swift support (stolen from doom)";

  config.programs.emacs.init = {
    ide.treesitterGrammars.swift = "https://github.com/alex-pinkus/tree-sitter-swift";
    usePackage = lib.mkIf ide.languages.swift.enable {
      swift-ts-mode = {
        enable = true;
        mode = [''"\\.swift\\'"''];
        extraPackages = lib.mkIf (ide.lsp-bridge.enable || ide.eglot.enable || ide.lsp.enable || ide.lspce.enable) [pkgs.sourcekit-lsp];
        eglot = lib.mkIf ide.eglot.enable ''"sourcekit-lsp"'';
        lsp = ide.lsp.enable;
        lspce = ide.lspce.enable;
        config = lib.mkIf ide.lspce.enable ''(nix-emacs-lspce-add-server-program "swift" "sourcekit-lsp")'';
      };

      lsp-sourcekit = lib.mkIf ide.lsp.enable {
        enable = true;
        after = ["swift-ts-mode"];
      };
    };
  } ;
}
