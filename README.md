# SysCoLab

Terminal SSH cockpit — check/install SSH, share this PC or connect to another,
then work in a tabbed terminal with a live status panel of the remote machine.

Developer: **Hrishikesh Jadhav**

This repo hosts **prebuilt binaries only** (as [Releases](../../releases)). Source is closed;
this is the public download surface.

## Install

macOS / Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/hrishi-anveshak/syscolab-releases/main/install.sh | sh
```

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/hrishi-anveshak/syscolab-releases/main/install.ps1 | iex
```

Then run:

```sh
syscolab
```

The installer detects your OS/architecture, downloads the matching binary from the
[latest release](../../releases/latest), and drops it on your `PATH`
(`~/.local/bin` on macOS/Linux, `%USERPROFILE%\.syscolab\bin` on Windows).

## What it does

1. **Setup** — detects the SSH client/server, installs and enables autostart if missing (per-OS).
2. **Use this PC** — shows your IP, username, a copyable `ssh user@ip` command, and a live table of
   connected clients (survives closing and reopening the app). Optional **Cloudflare Tunnel** button
   installs `cloudflared` and exposes this machine's SSH over a public URL.
3. **Use another PC** — enter username/host/password, watches the real `ssh` handshake and on
   success drops you into a split view: tabbed terminals on the left (`+` to open more,
   mouse-clickable tabs, `ctrl+t`/`ctrl+w` to add/close, `ctrl+q` to disconnect) and a live status
   panel on the right (uptime/load, users, memory/disk, network throughput, top processes).
4. Press `t` any time to change the color theme.

## Building your own binary from source

Source is private. If you have access, clone it and see `BUILD.md`:

```sh
git clone https://github.com/hrishi-anveshak/syscolab
cd syscolab
python3 -m venv .buildenv && source .buildenv/bin/activate
pip install -e . pyinstaller
pyinstaller --onefile --name syscolab --paths src \
  --collect-all textual --collect-all pyte \
  --add-data "src/syscolab/styles.tcss:syscolab" \
  entry.py
```

## Publishing a new release (maintainer)

Build on each OS (PyInstaller doesn't cross-compile — see `BUILD.md` in the source repo), name the
binaries to match what `install.sh`/`install.ps1` look for, then:

```sh
gh release create v0.1.1 \
  syscolab-linux-x86_64 \
  syscolab-macos-arm64 \
  syscolab-windows-x86_64.exe \
  --repo hrishi-anveshak/syscolab-releases \
  --title "v0.1.1" \
  --notes "What changed..."
```

The installers always fetch the `latest` tag, so nothing else needs updating.
