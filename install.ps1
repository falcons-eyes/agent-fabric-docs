# Agent Fabric installer (Windows, PowerShell).
#
#   powershell -ExecutionPolicy ByPass -c "irm https://raw.githubusercontent.com/falcons-eyes/agent-fabric-docs/main/install.ps1 | iex"
#
# Env overrides:
#   $env:AGENT_FABRIC_VERSION       release tag (default: latest)
#   $env:AGENT_FABRIC_INSTALL_DIR   install dir (default: %USERPROFILE%\.falcon\bin)

$ErrorActionPreference = "Stop"

$Repo = "falcons-eyes/agent-fabric-docs" # public distribution repo (binaries via its GitHub Releases)
$Version = if ($env:AGENT_FABRIC_VERSION) { $env:AGENT_FABRIC_VERSION } else { "latest" }
$InstallDir = if ($env:AGENT_FABRIC_INSTALL_DIR) { $env:AGENT_FABRIC_INSTALL_DIR } else { Join-Path $env:USERPROFILE ".falcon\bin" }

# minisign public key that signs official releases (key ID C363AC965984399A). Baked in
# so a compromised release channel cannot swap the verifying key. Checked fail-closed
# when the `minisign` tool is present; otherwise the SHA-256 checksum stays the floor.
$PubKey = "RWSaOYRZlqxjw1w2cOBah+T54hogN/eO/+1Pn1ptReOLjPHp4NTdS9Lt"

function Say($m) { Write-Host $m }

Say "Agent Fabric installer"

# arch (Windows release ships amd64; arm64 can be added later)
$arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "amd64" }
$target = "windows-$arch"
$asset = "falcon-$target.zip"
Say "  platform: $target"
Say "  version:  $Version"

$base = if ($Version -eq "latest") {
	"https://github.com/$Repo/releases/latest/download"
} else {
	"https://github.com/$Repo/releases/download/$Version"
}

$tmp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("af-" + [guid]::NewGuid()))
try {
	$zip = Join-Path $tmp $asset
	Say "  downloading $asset"
	Invoke-WebRequest -Uri "$base/$asset" -OutFile $zip -UseBasicParsing

	# checksum verification — FAIL CLOSED: require checksums.txt + a verified match
	# before running an executable. Errors propagate ($ErrorActionPreference=Stop);
	# never swallow a missing file, an unlisted asset, or a mismatch.
	$sumsFile = Join-Path $tmp "checksums.txt"
	Invoke-WebRequest -Uri "$base/checksums.txt" -OutFile $sumsFile -UseBasicParsing
	$entry = Select-String -Path $sumsFile -Pattern ([regex]::Escape($asset)) | Select-Object -First 1
	if (-not $entry) { throw "no checksum entry for $asset in checksums.txt - refusing to install" }
	$want = $entry.Line.Split(" ")[0]
	$got = (Get-FileHash -Algorithm SHA256 $zip).Hash.ToLower()
	if ($want.ToLower() -ne $got) { throw "checksum verification FAILED for $asset" }
	Say "  checksum:  ok"

	# Signature (minisign) — the authenticity check the checksum can't provide (both live
	# in the same release). Verified fail-closed against $PubKey when the tool is present.
	# A missing signature (pre-signing release) or a missing tool falls back to the
	# checksum floor above, and says so — never a silent skip.
	$sig = Join-Path $tmp "$asset.minisig"
	$haveSig = $true
	try { Invoke-WebRequest -Uri "$base/$asset.minisig" -OutFile $sig -UseBasicParsing } catch { $haveSig = $false }
	if (-not $haveSig) {
		Say "  signature: none published for this release (checksum-verified)"
	} elseif (Get-Command minisign -ErrorAction SilentlyContinue) {
		& minisign -Vm $zip -P $PubKey *> $null
		if ($LASTEXITCODE -ne 0) { throw "signature verification FAILED for $asset - refusing to install a tampered artifact" }
		Say "  signature: ok (minisign)"
	} else {
		Say "  signature: present, but 'minisign' is not installed - verified by checksum only"
		Say "             install minisign and re-run to verify the release signature"
	}

	Expand-Archive -Path $zip -DestinationPath $tmp -Force
	New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
	foreach ($b in @("falcon.exe", "afd.exe", "aflocal.exe")) {
		$src = Join-Path $tmp $b
		if (Test-Path $src) {
			Copy-Item -Force $src (Join-Path $InstallDir $b)
			Say "  installed $b -> $InstallDir\$b"
		}
	}

	# add to user PATH
	$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
	if ($userPath -notlike "*$InstallDir*") {
		[Environment]::SetEnvironmentVariable("Path", "$userPath;$InstallDir", "User")
		Say ""
		Say "Added $InstallDir to your user PATH. Restart your terminal."
	}
	Say ""
	Say "Done. Try:  falcon --help"
}
finally {
	Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
