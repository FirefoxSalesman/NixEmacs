{ pkgs, config, lib, ... }:

let ide = config.programs.emacs.init.ide;
in {
  options.programs.emacs.init.ide.languages.bash.enable =
    lib.mkEnableOption "enables bash support";

  config = lib.mkIf ide.languages.bash.enable {
    programs.emacs.init.usePackage.bash-ts-mode = {
      enable = true;
      babel = lib.mkIf ide.languages.org.enable "shell";
      extraPackages = if ide.lsp-bridge.enable || ide.lspce.enable
      || ide.lsp.enable || ide.eglot.enable then
        with pkgs; [ nodePackages.bash-language-server ]
      else
        [ ];
      mode = [ ''"\\.sh\\'"'' ];
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      lspce = ide.lspce.enable;
      config = lib.mkIf ide.lspce.enable ''(nix-emacs-lspce-add-server-program '("sh" "bash") "bash-language-server" "start")'';
    };
  };
}
