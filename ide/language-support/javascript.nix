{
  pkgs,
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
  completions = config.programs.emacs.init.completions;
  fakeIf = cond: pkg: if cond then [ pkg ] else [ ];
  wantRass =
    (
      ide.languages.javascript.wantBiome
      || ide.languages.javascript.wantOxfmt
      || ide.languages.javascript.wantOxlint
      || ide.languages.javascript.wantEslint
    )
    && (ide.eglot.enable || ide.lspce.enable);
in
{
  options.programs.emacs.init.ide.languages.javascript = {
    enable = lib.mkEnableOption "enables javascript support";
    languageServer = lib.mkOption {
      type = lib.types.enum [
        "typescript-language-server"
        "deno"
      ];
      default = "typescript-language-server";
      description = "the language server to use with javascript/typescript. Can be either typescript-language-server or deno.";
    };
    wantEslint = lib.mkEnableOption "Enables eslint in addition to the other js/ts language servers.";
    wantOxlint = lib.mkEnableOption "Enables oxlint in addition to the other js/ts language servers.";
    wantOxfmt = lib.mkEnableOption "Enables oxfmt in addition to the other js/ts language servers.";
    wantBiome = lib.mkEnableOption "Enables biome in addition to the other js/ts language servers.";
  };

  config.programs.emacs.init = lib.mkIf ide.languages.javascript.enable {
    completions.tempel.templates.js-ts-mode = lib.mkIf completions.tempel.enable {
      clg = ''"console.log(" p ");"'';
      doc = ''"/**" n> " * " q n " */"'';
      anfn = ''"(" p ") => {" n> q n "};"'';
      qs = ''"document.querySelector(\"" q "\");"'';
      "if" = ''"if (" p ") {" n> q n "}"'';
    };

    ide = {
      treesitter.wantTreesitter = true;
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "js-ts-mode" ];
    };

    tools.apheleia.modeFormatters.js-ts-mode = lib.mkIf (
      config.programs.emacs.init.tools.apheleia.enable && (ide.eglot.enable || ide.lsp.enable)
    ) (lib.mkDefault (if ide.eglot.enable then "eglot" else "lsp"));

    usePackage = {
      js-ts-mode = {
        enable = true;
        babel = lib.mkIf ide.languages.org.enable "js";
        extraPackages =
          (
            if ide.lsp-bridge.enable || ide.lspce.enable || ide.lsp.enable || ide.eglot.enable then
              (
                if ide.languages.javascript.languageServer == "deno" then
                  [ pkgs.deno ]
                else
                  [ pkgs.typescript-language-server ]
              )
              ++ (fakeIf ide.languages.javascript.wantEslint pkgs.vscode-eslint-language-server)
              ++ (fakeIf ide.languages.javascript.wantOxlint pkgs.oxlint)
              ++ (fakeIf ide.languages.javascript.wantOxfmt pkgs.oxfmt)
              ++ (fakeIf ide.languages.javascript.wantBiome pkgs.biome)
              ++ (fakeIf wantRass pkgs.rassumfrassum)
            else
              [ ]
          )
          ++ (fakeIf (ide.dap.enable || ide.dape.enable) pkgs.vscode-js-debug);
        mode = [ ''"\\.js\\'"'' ];
        eglot = ide.eglot.enable;
        symex = ide.symex;
        lsp = ide.lsp.enable;
        lspce = lib.mkIf ide.lspce.enable ''"js" ${if wantRass then ''"rass" "--"'' else ""} ${
          if ide.languages.javascript.languageServer == "deno" then
            ''"typescript-language-server" "--stdio"''
          else
            ''"deno" "lsp"''
        } ${if ide.languages.javascript.wantBiome then ''"--" "biome" "lsp-proxy"'' else ""} ${
          if ide.languages.javascript.wantOxfmt then ''"--" "oxfmt" "--lsp"'' else ""
        } ${if ide.languages.javascript.wantOxlint then ''"--" "oxlint" "--lsp"'' else ""} ${
          if ide.languages.javascript.wantEslint then
            ''"--" "vscode-eslint-language-server" "--stdio"''
          else
            ""
        } '';
        config = lib.mkIf ide.dap.enable "(require 'dap-node)";
      };

      eglot-typescript-preset = lib.mkIf ide.eglot.enable {
        enable = true;
        after = [ "eglot" ];
        setopt = {
          eglot-typescript-preset-lsp-server = lib.mkDefault (
            if wantRass then "'rass" else "'${ide.languages.javascript.languageServer}"
          );
          eglot-typescript-preset-rass-tools = lib.mkIf wantRass (
            lib.mkDefault (
              lib.concatLists [
                (
                  if ide.languages.javascript.languageServer == "deno" then
                    [ "'deno" ]
                  else
                    [ "'typescript-language-server" ]
                )
                (fakeIf ide.languages.javascript.wantBiome "'biome")
                (fakeIf ide.languages.javascript.wantOxfmt "'oxfmt")
                (fakeIf ide.languages.javascript.wantOxlint "'oxlint")
                (fakeIf ide.languages.javascript.wantEslint "'eslint")
              ]
            )
          );
        };
      };
    };
  };
}
