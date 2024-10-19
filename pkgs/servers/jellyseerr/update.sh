#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts nix prefetch-pnpm-deps

set -eu -o pipefail

version=${1:-$(curl -s https://api.github.com/repos/Fallenbagel/jellyseerr/releases/latest | jq --raw-output '.tag_name[1:]')}
update-source-version jellyseerr $version

nix_file=$(nix-instantiate --eval --strict -A "jellyseerr.meta.position" | sed -re 's/^"(.*):[0-9]+"$/\1/')
nix_dir=$(dirname $nix_file)
cp $(nix-instantiate --eval --expr 'with import ./default.nix { }; "${jellyseerr.src}/package.json"' | sed 's/"//g') $nix_dir

old_pnpm_hash=$(nix-instantiate --eval --strict -A "jellyseerr.pnpmDeps.hash" | tr -d '"' | sed -re 's|[+]|\\&|g')
lock_file=$(nix-instantiate --eval --expr 'with import ./default.nix { }; "${jellyseerr.src}/pnpm-lock.yaml"' | sed 's/"//g')
new_pnpm_hash=$(nix hash to-sri --type sha256 $(prefetch-pnpm-deps $lock_file))
sed -i "$nix_file" -re "s|\"$old_pnpm_hash\"|\"$new_pnpm_hash\"|"
