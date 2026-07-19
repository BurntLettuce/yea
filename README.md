# NixOS Config

## Hosts

Rebuild any host with:
```bash
cd /etc/nixos
sudo nixos-rebuild switch --flake .#<hostname>
```

## Secrets (sops-nix)

hosts/common/secrets/secrets.yaml
```
Recipients are defined in:
```
hosts/common/.sops.yaml
```

### Editing secrets

**Never edit `secrets.yaml` directly.** Always go through sops so it stays encrypted on disk:
```bash
cd /etc/nixos/hosts/common
sops secrets/secrets.yaml
```

### Adding new device

1. Get age public key (SSH host key):
   ```bash
   nix-shell -p ssh-to-age --run "ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub"
   ```
   (Generate the host key first if missing: `sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""`)
2. Add new key + a label to `hosts/common/.sops.yaml` under `keys:` and `key_groups:`.
3. From any machine that can decrypt the file, run:
   ```bash
   cd /etc/nixos/hosts/common
   sops updatekeys secrets/secrets.yaml
   ```
4. Commit + push.

## Notes
