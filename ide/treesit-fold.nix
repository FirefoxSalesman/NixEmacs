{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.treesit-fold = {
    enable = lib.mkEnableOption "Enable code folding via treesitter";
    enabledModes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["bash-ts-mode" "emacs-lisp-mode"];
      description = "List of major modes to enable treesit-fold-mode in.";
    };
  };
  config.programs.emacs.init.usePackage.treesit-fold = lib.mkIf ide.treesit-fold.enable {
    enable = true;
    # ghookf = ["((gen-mode-hooks '(bash-ts c-ts css-ts emacs-lisp erlang-ts go-ts haskell-ts html-ts java-ts js-ts json-ts json5-ts julia-ts kotlin-ts lua-ts make nix-ts python-ts ess-r rustic scala-ts svelte-ts swift-ts toml-ts typescript-ts vimscript-ts yaml-ts zig-ts)) 'treesit-fold-mode)"];
    hook = lib.map (mode: "(${mode} . treesit-fold-mode)") ide.treesit-fold.enabledModes;
  };
}
