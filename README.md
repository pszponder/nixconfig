# Wrapped Dendritic Nix 

```sh
sudo nixos-rebuild switch --flake .#tpx1
```

```
[piotr@nixos:~/repos/github/pszponder/nixconfig]$ sudo nixos-rebuild switch --flake .#tpx1
[sudo] password for piotr: 
warning: creating lock file "/home/piotr/repos/github/pszponder/nixconfig/flake.lock": 
• Added input 'flake-parts':
    'github:hercules-ci/flake-parts/024633cd702b10285db5cb19b40ad48d2399ba60?narHash=sha256-zTwuwezD0w3hpga6a6P8emidzAZFyWqlNeRBlpWOOl8%3D' (2026-10-01)
• Added input 'flake-parts/nixpkgs-lib':
    'github:nix-community/nixpkgs.lib/f7cd230690d9fc982d06129f9189b101fddcfa3b?narHash=sha256-oujbxmVKDhci2E4EM3KyAbRUgp5/IsCoiA/LfEF7OOk%3D' (2026-09-27)
• Added input 'import-tree':
    'github:vic/import-tree/eb1b52eaecc57f7c136d07ae8a93e724dfecac46?narHash=sha256-ljEMTXP/rH0tOvDzc9gzwww6KcHRPRnEHzd9lK48V7s%3D' (2026-09-03)
• Added input 'nixpkgs':
    'github:nixos/nixpkgs/da6dc0e7b26060f2f71ce3ef7088fb56ee44fa36?narHash=sha256-MlvRfa1O5Cqc2/a%2BgG%2Bl9TSuowEoCKCmrJ1d9oAVm0I%3D' (2026-10-21)
• Added input 'nixpkgs-unstable':
    'github:nixos/nixpkgs/3ec636362e1816bc2f0888fa0fa2c69f1bc9e504?narHash=sha256-rZLrzrC6i%2BjnTAlvPZHogKDulY7WWDEv9hJeHieO7Zw%3D' (2026-10-23)
• Added input 'wrappers':
    'github:nix-community/nix-wrapper-modules/e40208b34e08f764e6b972eb0ee919706e960eb2?narHash=sha256-rasFTcWJo7CdUaCFcxcDTnMWlY6WxZo/X6EsbEqgIpM%3D' (2026-10-20)
• Added input 'wrappers/nixpkgs':
    'github:NixOS/nixpkgs/319e4cebef10cbb636c6ea392137b52ad105336a?narHash=sha256-t1hT8UW97rFCWCJO7/pClvu0AhLN5V3uir2M0ic4w/Q%3D' (2026-10-14)
error:
       … while calling the 'seq' builtin
         at «github:nixos/nixpkgs/da6dc0e7b26060f2f71ce3ef7088fb56ee44fa36»/lib/modules.nix:402:18:
          401|         options = checked options;
          402|         config = checked (removeAttrs config [ "_module" ]);
             |                  ^
          403|         _module = checked (config._module);

       … while evaluating a branch condition
         at «github:nixos/nixpkgs/da6dc0e7b26060f2f71ce3ef7088fb56ee44fa36»/lib/modules.nix:305:9:
          304|       checkUnmatched =
          305|         if config._module.check && config._module.freeformType == null && merged.unmatchedDefns != [ ] then
             |         ^
          306|           let

       … while evaluating the module argument `pkgs' in "/nix/store/640irzgl08asrnjly4dspdbx8lz3cvqr-source/nixos/modules/services/hardware/bluetooth.nix":

       … noting that argument `pkgs` is not externally provided, so querying `_module.args` instead, requiring `config`

       … while evaluating the option `nixpkgs.localSystem':

       … while evaluating the option `nixpkgs.system':

       (stack trace truncated; use '--show-trace' to show the full, detailed trace)

       error: Neither nixpkgs.hostPlatform nor the legacy option nixpkgs.system has been set.
       You can set nixpkgs.hostPlatform in hardware-configuration.nix by re-running
       a recent version of nixos-generate-config.
       The option nixpkgs.system is still fully supported for NixOS 22.05 interoperability,
       but will be deprecated in the future, so we recommend to set nixpkgs.hostPlatform.
Command 'nix --extra-experimental-features 'nix-command flakes' build --print-out-paths '.#nixosConfigurations."tpx1".config.system.build.nixos-rebuild' --no-link' returned non-zero exit status 1.
```





## Resources / References
- 
