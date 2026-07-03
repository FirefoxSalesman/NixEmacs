{ pkgs, lib }:
pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (pkgs.vscodium) version src;
  pname = "vscode-langservers-extracted";

  sourceRoot =
    if pkgs.stdenvNoCC.hostPlatform.isDarwin then
      "VSCodium.app/Contents/Resources/app/extensions"
    else
      "resources/app/extensions";

  nativeBuildInputs = [
    pkgs.makeBinaryWrapper
  ]
  # The Darwin release is a zip.
  # stdenv unpacks the Linux tarball (tar.gz) natively.
  # FIXME: update vscodium.src to use fetchTarball & fetchZip
  ++ lib.optionals pkgs.stdenvNoCC.hostPlatform.isDarwin [
    pkgs.unzip
  ];

  __structuredAttrs = true;
  strictDeps = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    	runHook preInstall

          server="html-language-features/server/dist/node/htmlServerMain.js"
          install -Dm644 "$server" \
            "$out/lib/extensions/$server"
          makeBinaryWrapper ${lib.getExe pkgs.nodejs} "$out/bin/vscode-html-language-server" \
            --add-flag "$out/lib/extensions/$server"

        # Use VSCodium bundled TypeScript
        mkdir -p "$out/lib/extensions/node_modules"
        cp -a node_modules/typescript "$out/lib/extensions/node_modules/typescript"

        runHook postInstall
  '';

  passthru.tests.initialization =
    pkgs.runCommandLocal "vscode-langservers-extracted-initialization"
      {
        nativeBuildInputs = [ finalAttrs.finalPackage ];
      }
      ''
        request() {
          init_request='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":null,"rootUri":null,"capabilities":{}}}'
          content_length=''${#init_request}
          printf "Content-Length: %d\r\n\r\n%s" "$content_length" "$init_request"
          sleep 1
        }

        echo "Checking html language server"
        response=$(request | timeout 3 "vscode-html-language-server" --stdio) || true
        grep -q '"capabilities"' <<< "$response"

        touch $out
        	  '';

  meta = {
    inherit (pkgs.vscodium.meta) license platforms;
    description = "HTML language server extracted from vscode";
  };
})
