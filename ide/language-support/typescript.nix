{
  config,
  lib,
  ...
}:

let
  ide = config.programs.emacs.init.ide;
  completions = config.programs.emacs.init.completions;
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
  options.programs.emacs.init.ide.languages.typescript.enable =
    lib.mkEnableOption "enables typescript support";

  config.programs.emacs.init = lib.mkIf ide.languages.typescript.enable {
    completions.tempel.templates.typescript-ts-mode = lib.mkIf completions.tempel.enable {
      clg = ''"console.log(" p ");"'';
      doc = ''"/**" n> " * " q n " */"'';
      anfn = ''"(" p ") => {" n> q n "};"'';
      qs = ''"document.querySelector(\"" q "\");"'';
      "if" = ''"if (" p ") {" n> q n "}"'';
    };
    ide = {
      treesitter.wantTreesitter = true;
      treesit-fold.enabledModes = lib.mkIf ide.treesit-fold.enable [ "typescript-ts-mode" ];
      languages.javascript.enable = true;
    };
    usePackage.typescript-ts-mode = {
      enable = true;
      babel = lib.mkIf ide.languages.org.enable "typescript";
      mode = [ ''"\\.ts\\'"'' ];
      eglot = ide.eglot.enable;
      symex = ide.symex;
      lsp = ide.lsp.enable;
      lspce =
        lib.mkIf ide.lspce.enable lib.mkIf ide.lspce.enable
          '''("tsx" "typescript") ${if wantRass then ''"rass" "--"'' else ""} ${
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
          }'';
      config = lib.mkIf ide.dap.enable "(require 'dap-node)";
    };
  };
}
