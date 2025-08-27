{ lib, ... }:

{
  imports = [
    ./eglot.nix
    ./lsp-mode.nix
    ./lsp-bridge.nix
    ./lspce.nix
  ];
}
