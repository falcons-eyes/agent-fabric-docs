#!/bin/sh
# Agent Fabric installer (macOS / Linux).
#
#   curl -LsSf https://raw.githubusercontent.com/falcons-eyes/agent-fabric-docs/main/install.sh | sh
#
# Env overrides:
#   AGENT_FABRIC_VERSION       release tag to install (default: latest)
#   AGENT_FABRIC_INSTALL_DIR   install directory (default: $HOME/.local/bin)
#   AGENT_FABRIC_NO_MODIFY_PATH set to 1 to skip editing shell profiles
set -eu

REPO="falcons-eyes/agent-fabric-docs" # public distribution repo (binaries via its GitHub Releases)
BINARIES="falcon afd aflocal"
VERSION="${AGENT_FABRIC_VERSION:-latest}"
INSTALL_DIR="${AGENT_FABRIC_INSTALL_DIR:-$HOME/.local/bin}"

main() {
	say "Agent Fabric installer"

	need_cmd uname
	need_cmd mkdir
	need_cmd tar

	DOWNLOADER=""
	if check_cmd curl; then DOWNLOADER="curl"
	elif check_cmd wget; then DOWNLOADER="wget"
	else err "need curl or wget"; fi

	OS="$(detect_os)"
	ARCH="$(detect_arch)"
	TARGET="${OS}-${ARCH}"
	say "  platform: ${TARGET}"
	say "  version:  ${VERSION}"

	ASSET="falcon-${TARGET}.tar.gz"
	if [ "$VERSION" = "latest" ]; then
		BASE="https://github.com/${REPO}/releases/latest/download"
	else
		BASE="https://github.com/${REPO}/releases/download/${VERSION}"
	fi

	TMP="$(mktemp -d)"
	trap 'rm -rf "$TMP"' EXIT

	say "  downloading ${ASSET}"
	download "${BASE}/${ASSET}" "${TMP}/${ASSET}" \
		|| err "download failed — no release asset for ${TARGET}? (see ${BASE})"

	# checksum verification — FAIL CLOSED: require checksums.txt and a verified match
	# before installing an executable. No skip-on-absence, no skip-if-unlisted.
	download "${BASE}/checksums.txt" "${TMP}/checksums.txt" \
		|| err "no checksums.txt for ${VERSION} — refusing to install an unverified artifact"
	verify_checksum "${TMP}" "${ASSET}" || err "checksum verification FAILED for ${ASSET}"
	say "  checksum:  ok"

	tar -xzf "${TMP}/${ASSET}" -C "${TMP}"
	mkdir -p "${INSTALL_DIR}"
	for b in $BINARIES; do
		if [ -f "${TMP}/${b}" ]; then
			install -m 0755 "${TMP}/${b}" "${INSTALL_DIR}/${b}"
			say "  installed ${b} -> ${INSTALL_DIR}/${b}"
		fi
	done

	ensure_path "${INSTALL_DIR}"

	say ""
	say "Done. Try:  falcon --help"
}

detect_os() {
	case "$(uname -s)" in
		Darwin) echo "darwin" ;;
		Linux) echo "linux" ;;
		*) err "unsupported OS: $(uname -s) (use install.ps1 on Windows)" ;;
	esac
}

detect_arch() {
	case "$(uname -m)" in
		x86_64 | amd64) echo "amd64" ;;
		arm64 | aarch64) echo "arm64" ;;
		*) err "unsupported architecture: $(uname -m)" ;;
	esac
}

download() {
	# download <url> <dest>
	if [ "$DOWNLOADER" = "curl" ]; then
		curl -fsSL "$1" -o "$2"
	else
		wget -q "$1" -O "$2"
	fi
}

verify_checksum() {
	# verify_checksum <dir> <asset>  — fail closed: an unlisted asset or a missing
	# sha256 tool is an error, not a silent pass.
	dir="$1"; asset="$2"
	want="$(grep " ${asset}\$" "${dir}/checksums.txt" | awk '{print $1}')"
	[ -n "$want" ] || err "no checksum entry for ${asset} in checksums.txt"
	if check_cmd sha256sum; then
		got="$(sha256sum "${dir}/${asset}" | awk '{print $1}')"
	elif check_cmd shasum; then
		got="$(shasum -a 256 "${dir}/${asset}" | awk '{print $1}')"
	else
		err "need 'sha256sum' or 'shasum' to verify the download"
	fi
	[ "$want" = "$got" ]
}

ensure_path() {
	dir="$1"
	case ":${PATH}:" in
		*":${dir}:"*) return 0 ;;
	esac
	if [ "${AGENT_FABRIC_NO_MODIFY_PATH:-0}" = "1" ]; then
		say ""
		say "Add to PATH:  export PATH=\"${dir}:\$PATH\""
		return 0
	fi
	line="export PATH=\"${dir}:\$PATH\""
	added=""
	for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile"; do
		[ -e "$rc" ] || continue
		if ! grep -qsF "$dir" "$rc"; then
			printf '\n# added by agent-fabric installer\n%s\n' "$line" >> "$rc"
			added="$added $rc"
		fi
	done
	# always ensure at least .profile exists with the line
	if [ -z "$added" ] && [ ! -e "$HOME/.zshrc" ] && [ ! -e "$HOME/.bashrc" ]; then
		printf '\n# added by agent-fabric installer\n%s\n' "$line" >> "$HOME/.profile"
		added=" $HOME/.profile"
	fi
	if [ -n "$added" ]; then
		say ""
		say "Added ${dir} to PATH in:${added}"
		say "Restart your shell or run:  ${line}"
	fi
}

say() { printf '%s\n' "$*"; }
err() { printf 'error: %s\n' "$*" >&2; exit 1; }
check_cmd() { command -v "$1" >/dev/null 2>&1; }
need_cmd() { check_cmd "$1" || err "need '$1' (command not found)"; }

main "$@"
