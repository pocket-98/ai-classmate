# nixos configuration
* flake configuration for nixos-unstable repo and to get llm-agents.nix
* minimum configuration flake in `min/` to allow for majority of disk space to be freed

## min
* `cd /etc/nixos/min`
* `sudo nixos-rebuild switch --flake && sudo reboot now`
* login from tty
* `sudo nixos-collect-garbage -d` frees majority of system
* `sudo nix-store --optimise`

# rebuild full system configuration
* `cd /etc/nixos`
* `sudo nixos-rebuild switch --flake && sudo reboot now`
