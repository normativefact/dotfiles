# NixOS and Home Manager dotfiles

This flake provides `nixosConfigurations.nixos` and
`homeConfigurations.normativefact` for x86_64 Linux. NixOS owns system services,
privileged wrappers, and PAM; Home Manager owns personal application settings.
The username and home directory are configured in `home-manager/home.nix`.

## Machine-local configuration

Hardware configuration is intentionally **not tracked**. On the target NixOS
machine, generate it before evaluating or rebuilding the system:

```sh
cd /path/to/dotfiles
nixos-generate-config --show-hardware-config > nixos/hardware-configuration.nix
```

Review the generated file before using it. Filesystem UUIDs, CPU/GPU settings,
swap configuration, and hibernation resume offsets belong in that file or in
`nixos/local.nix`, which is also ignored. Hibernation offsets must be determined
for the actual swapfile; do not copy them from another machine.

For example, an AMD machine can opt into the existing graphics module using
`nixos/local.nix`:

```nix
{ ... }: {
  imports = [ ./modules/graphics.nix ];
}
```

Optional personal overrides can go in the ignored `home-manager/local.nix`.
The repository installs Neovim but does not supply a Neovim configuration;
manage your existing configuration independently or add it declaratively.

**Use `path:` when applying these configurations.** Git-backed flakes exclude
ignored hardware and local override files. A path flake includes those files
without committing them. Keep credentials outside the checkout and Nix
expressions: path flakes copy their source into the Nix store.

## Validate and apply

From the repository root, with Nix flakes enabled:

```sh
nix eval --no-write-lock-file --raw "path:$PWD#nixosConfigurations.nixos.config.system.build.toplevel.drvPath"
nix eval --no-write-lock-file --raw "path:$PWD#homeConfigurations.normativefact.activationPackage.drvPath"

# Build first; this does not activate the configuration.
nix build --no-write-lock-file --no-link "path:$PWD#nixosConfigurations.nixos.config.system.build.toplevel"
nix build --no-write-lock-file --no-link "path:$PWD#homeConfigurations.normativefact.activationPackage"

# Apply only on the intended NixOS machine and user account.
sudo nixos-rebuild switch --flake "path:$PWD#nixos"
home-manager switch --flake "path:$PWD#normativefact"
```

Apply the system configuration before Home Manager on a new machine. Espanso's
Wayland service depends on the system capability wrapper, and Hyprlock depends
on system PAM configuration. Standalone Home Manager activation does not create
these system integrations.

Git commits are signed using `~/.ssh/id_ed25519.pub`; provision the matching
private key securely and make it available to SSH signing, or override signing
locally. AI tools read their API keys from environment variables; keys are not
provided by this repository.

Hyprland and Niri can both be installed. Niri starts Waybar with its separate
`waybar/niri.json` configuration; Hyprland uses the default configuration.
