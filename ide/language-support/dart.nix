{ config, lib, ... }:

let
  ide = config.programs.emacs.init.ide;
in
{
  options.programs.emacs.init.ide.languages.dart = {
    enable = lib.mkEnableOption "Enables dart support. You'll need to install the language server yourself, as I can't find it in nixpkgs";
    flutter = lib.mkEnableOption "Enables flutter support";
  };

  config.programs.emacs.init.usePackage = lib.mkIf ide.languages.dart.enable {
    dart-mode = {
      enable = true;
      eglot = ide.eglot.enable;
      lsp = ide.lsp.enable;
      lspce = lib.mkIf ide.lspce.enable ''"dart" "dart" "language-server"'';
      config = lib.mkIf ide.dap.enable "(dap-dart-setup)";
    };

    flutter = lib.mkIf ide.languages.dart.flutter {
      enable = true;
      after = [ "dart-mode" ];
      generalTwo.local-leader.dart-ts-mode-map =
        lib.mkIf config.programs.emacs.init.keybinds.leader-keys.enable
          {
            "q" = lib.mkDefault "'flutter-quit";
            "h" = lib.mkDefault "'flutter-hot-reload";
            "H" = lib.mkDefault "'flutter-hot-restart";
            "u" = lib.mkDefault "'flutter-run";
          };
    };

    hover = lib.mkIf ide.languages.dart.flutter {
      enable = true;
      after = [ "dart-mode" ];
    };

    lsp-dart = lib.mkIf ide.lsp.enable {
      enable = true;
      after = [ "lsp-mode" ];
    };
  };
}
