#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <app_path> <output_dmg_path>" >&2
    exit 1
fi

app_path="$1"
output_dmg_path="$2"

if [[ ! -d "$app_path" ]]; then
    echo "Error: app path does not exist: $app_path" >&2
    exit 1
fi

if [[ "$app_path" != *.app ]]; then
    echo "Error: app path must point to a .app bundle: $app_path" >&2
    exit 1
fi

output_dir="$(dirname "$output_dmg_path")"
mkdir -p "$output_dir"

temp_dir="$(mktemp -d)"
cleanup() {
    rm -rf "$temp_dir"
}
trap cleanup EXIT

staging_dir="$temp_dir/dmg-staging"
mkdir -p "$staging_dir"

ditto "$app_path" "$staging_dir/VoiceInk.app"
ln -s /Applications "$staging_dir/Applications"

rm -f "$output_dmg_path"
hdiutil create \
    -volname "VoiceInk" \
    -srcfolder "$staging_dir" \
    -ov \
    -format UDZO \
    "$output_dmg_path"

echo "Created DMG: $output_dmg_path"
echo "SHA256:"
shasum -a 256 "$output_dmg_path"
