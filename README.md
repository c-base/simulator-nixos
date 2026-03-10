# Usage:

To install, run this:
```
nixos-rebuild switch --flake github:c-base/simulator-nixos#simulator
```

To update, run

```
# In the git repo:
nix flake update --commit-lock-file --commit-lockfile-summary "chore: update flake dependencies"
git push ...

# On the target machine:
nixos-rebuild switch --flake github:c-base/simulator-nixos
```
