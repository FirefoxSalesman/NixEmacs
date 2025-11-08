{
  pkgs,
  lib,
  config,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.svelte.enable =
    lib.mkEnableOption "Enables svelte support";

  config.programs.emacs.init = lib.mkIf ide.languages.svelte.enable {
    ide = {
      treesitter.treesitterGrammars.svelte = "https://github.com/Himujjal/tree-sitter-svelte";
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "svelte-ts-mode" ];
    };
    usePackage.svelte-ts-mode = {
      enable = true;
      extraPackages = lib.mkIf (
        ide.eglot.enable || ide.lsp.enable || ide.lspce.enable || ide.lsp-bridge.enable
      ) [ pkgs.svelte-language-server ];
      mode = [ ''"\\.svelte\\'"'' ];
      eglot = ''("svelteserver" "--stdio")'';
      lsp = ide.lsp.enable;
      lspce = lib.mkIf ide.lspce.enable ''"svelte" "svelteserver" "--stdio"'';
      symex = ide.symex;
    };
  };
}
