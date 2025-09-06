{ pkgs, lib, config, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.svelte.enable = lib.mkEnableOption "Enables svelte support";

  config.programs.emacs.init = {
    ide.treesitterGrammars.svelte = "https://github.com/Himujjal/tree-sitter-svelte";
    usePackage.svelte-ts-mode = lib.mkIf ide.languages.svelte.enable {
      enable = true;
      extraPackages = lib.mkIf (ide.eglot.enable || ide.lsp.enable || ide.lspce.enable || ide.lsp-bridge.enable) [pkgs.svelte-language-server];
      mode = [''"\\.svelte\\'"''];
      eglot = ''("svelteserver" "--stdio")'';
      lsp = ide.lsp.enable;
      lspce = ide.lspce.enable;
      config = lib.mkIf ide.lspce.enable ''
        (with-eval-after-load 'lspce (add-to-list 'lspce-server-programs '("svelte" "svelteserver" "--stdio")))
      '';
    };
  };
}
