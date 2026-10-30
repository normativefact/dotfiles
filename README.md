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

Use the `rebuild` helper below: it automatically includes ignored and untracked
files from this checkout, without staging or committing them. Keep credentials
outside the checkout and Nix expressions, since the source is copied into the
Nix store. Ordinary Git-backed flake commands still exclude ignored files;
the helper handles this distinction for you.

## Validate and apply

From the repository root, with Nix flakes enabled:

```sh
# Build first; this does not activate the configuration.
./rebuild system build
./rebuild home build

# Apply only on the intended NixOS machine and user account.
sudo ./rebuild system
./rebuild home
```

The action defaults to `switch`. Additional arguments are passed to the
underlying command, for example `./rebuild home build --show-trace`.
The `hms` Nushell alias runs `./rebuild home` from the repository root.
You can also invoke the helper by its absolute path from another directory;
it always uses the checkout containing the helper.

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

## Aider dependency compatibility

Aider uses the separately locked `nixpkgs-aider` input (NixOS 26.05). The main
nixpkgs input remains unstable. This avoids the unstable PostHog/MCP dependency
regression without allowing broken packages. To refresh only that package set,
run `nix flake update nixpkgs-aider`. Remove this separate input once Aider's
unstable dependency closure works again.
