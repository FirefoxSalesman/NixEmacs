{ ... }:

{
  imports = [
    ./language-support
    ./lsp-support
    ./dap-support
    ./project-management
    ./syntax-checkers
    ./direnv.nix
    ./copilot.nix
    ./treesit-fold.nix
    ./magit.nix
  ];
}
