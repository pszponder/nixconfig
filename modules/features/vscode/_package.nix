{ pkgs }:
(pkgs.vscode-with-extensions.override {
  vscode = pkgs.vscode.overrideAttrs (old: {
    version = "1.143.1";
    src = pkgs.fetchurl {
      name = "VSCode_1.143.1_linux-x64.tar.gz";
      url = "https://update.code.visualstudio.com/1.143.1/linux-x64/stable";
      hash = "sha256-SPZYBS5U4CChwb57N6wPmuOfB+jM2oBcY/BTz9pysr4=";
    };
    # The pinned tarball's CLI otherwise retains /usr/bin/env behind the GUI wrapper.
    postInstall = (old.postInstall or "") + ''
      substituteInPlace "$out/bin/code" "$out/lib/vscode/bin/code" \
        --replace-fail '#!/usr/bin/env sh' '#!${pkgs.runtimeShell}'
    '';
  });
  vscodeExtensions = import ./_extensions.nix { inherit pkgs; };
}).overrideAttrs
  (old: {
    buildCommand = old.buildCommand + ''
      for desktop_file in "$out/share/applications/"*.desktop; do
        desktop_source="$(readlink -f "$desktop_file")"
        cp --remove-destination "$desktop_source" "$desktop_file"
        substituteInPlace "$desktop_file" \
          --replace-fail 'Exec=code ' "Exec=$out/bin/code "
      done
    '';
  })
