{ pkgs }:
(with pkgs.vscode-extensions; [
  aaron-bond.better-comments
  anthropic.claude-code
  astral-sh.ty
  catppuccin.catppuccin-vsc
  catppuccin.catppuccin-vsc-icons
  charliermarsh.ruff
  enkia.tokyo-night
  github.vscode-github-actions
  mechatroner.rainbow-csv
  mhutchie.git-graph
  ms-azuretools.vscode-containers
  ms-azuretools.vscode-docker
  ms-python.debugpy
  ms-python.python
  ms-python.vscode-pylance
  ms-python.vscode-python-envs
  ms-toolsai.jupyter
  ms-toolsai.jupyter-keymap
  ms-toolsai.jupyter-renderers
  ms-toolsai.vscode-jupyter-cell-tags
  ms-toolsai.vscode-jupyter-slideshow
  ms-vscode-remote.remote-containers
  ms-vscode-remote.remote-ssh
  ms-vscode-remote.remote-ssh-edit
  ms-vscode-remote.vscode-remote-extensionpack
  ms-vscode.live-server
  ms-vscode.makefile-tools
  ms-vscode.remote-explorer
  ms-vscode.vscode-speech
  njpwerner.autodocstring
  redhat.vscode-yaml
  streetsidesoftware.code-spell-checker
  tamasfe.even-better-toml
  usernamehw.errorlens
  vscodevim.vim
  wholroyd.jinja
  yzhang.markdown-all-in-one
])
++ [
  (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "catppuccin";
      name = "catppuccin-vsc-pack";
      version = "1.0.2";
      hash = "sha256-jAoT3lmE2CGaahe2G2FF5bToM7sF9G1duEYO1a6+KS4=";
    };
  })
  (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "coenraads";
      name = "disableligatures";
      version = "0.0.10";
      hash = "sha256-ond8x77O/AK5PkU69doKQjmOtazpFvKgNcATGyl5HCQ=";
    };
  })
  (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "mermaidchart";
      name = "vscode-mermaid-chart";
      version = "2.8.2";
      hash = "sha256-IQyePfJVk86Ljs3X6eWRil/qt+t9dNYsYvBtdxQJ8L4=";
    };
  })
  (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "ms-vscode";
      name = "remote-server";
      version = "1.5.4";
      hash = "sha256-x0zD2MolMai8cCdNfn8kf58cf7oNe6XH1CDUfpJ/Zaw=";
    };
  })
  (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "openai";
      name = "chatgpt";
      version = "26.1021.22027";
      hash = "sha256-mlwapLUNDrm5wGw9f/0Y4ef6RZHahbGXO9Fink23X6k=";
      arch = "linux-x64";
    };
    # Patch bundled Codex/voice executables for NixOS.
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [
      pkgs.glib
      pkgs.libffi
      pkgs.zlib
    ];
  })
  (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "openai";
      name = "codex-audio";
      version = "26.1021.22027";
      hash = "sha256-Ze1N1RVT5bwtgWiYReqTuh2f2YOGwVmstt91L/GC9g8=";
    };
  })
  (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "sleistner";
      name = "vscode-fileutils";
      version = "3.10.3";
      hash = "sha256-v9oyoqqBcbFSOOyhPa4dUXjA2IVXlCTORs4nrFGSHzE=";
    };
  })
  (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "github";
      name = "vscode-pull-request-github";
      version = "0.172.0";
      hash = "sha256-UQWIbhtiFW2oHvySP4U64ssZfhIaZCBqpuOrmYjStxQ=";
    };
  })
]
