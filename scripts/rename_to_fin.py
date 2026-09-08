#!/usr/bin/env python3
"""One-shot brand rename: Minis -> Fin (identifiers, display strings, bundle IDs).

Deliberately NOT renamed (the sandbox/agent wire contract, see decision log):
  * `minis://` URL scheme, `/var/minis/...` sandbox paths, `minis-*` CLI tools,
    `minis-config`/`minis-open` etc. inside the Linux rootfs;
  * the OSC 1337 `MinisOpenURL=` marker and the symbols that parse it;
  * on-disk storage directories (`Library/MinisChat`, `MinisFileProvider`,
    `MinisConfig`, `MinisShared`, `minis-sessions`) so existing user data keeps
    loading; the shared-prefs / UserDefaults key names likewise;
  * `Ministral` (a Mistral model family) and anything lowercase-`minis` that is
    part of the protocol vocabulary;
  * GitHub URLs to upstream (OpenMinis/OpenMinis, OpenMinis/MinisSkills) and
    issue references like `OpenMinis#163` — those point at real upstream
    artefacts;
  * the `dev@openminis.app` support address and `openminis.app` launcher host.

Run from the repository root. Idempotent.
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# --------------------------------------------------------------------------
# Ordered replacement rules. Longer / more specific tokens first so that the
# generic `Minis` -> `Fin` rule never sees a token another rule owns.
# --------------------------------------------------------------------------
ORDERED_LITERALS: list[tuple[str, str]] = [
    # ---- Bundle / package identifiers -----------------------------------
    ("iCloud.com.openminis.app", "iCloud.com.mrmusic.fin"),
    ("group.com.openminis.app", "group.com.mrmusic.fin"),
    ("com.openminis.MinisTests", "com.mrmusic.fin.FinTests"),
    ("com.openminis.MinisUITests", "com.mrmusic.fin.FinUITests"),
    ("com.openminis.ish.", "com.mrmusic.fin.ish."),
    ("com.openminis.app", "com.mrmusic.fin"),
    ("com/openminis/app", "com/mrmusic/fin"),
    ("Java_com_openminis_app_", "Java_com_mrmusic_fin_"),
    # ---- Xcode module / target artefacts --------------------------------
    ("Minis-Swift.h", "Fin-Swift.h"),
    ("MinisApp-Bridging-Header.h", "FinApp-Bridging-Header.h"),
    ("MinisApp_Bridging_Header_h", "FinApp_Bridging_Header_h"),
    ("Minis.xcodeproj", "Fin.xcodeproj"),
    ("Minis.xcscheme", "Fin.xcscheme"),
    ("Minis.entitlements", "Fin.entitlements"),
    ("Minis.app", "Fin.app"),
    ("MinisTests.xctest", "FinTests.xctest"),
    ("MinisUITests.xctest", "FinUITests.xctest"),
    ("MinisShare.appex", "FinShare.appex"),
    ("MinisFileProvider.appex", "FinFileProvider.appex"),
    ("$s5Minis", "$s3Fin"),  # Swift mangled module prefix in a doc comment
    ("@testable import Minis", "@testable import Fin"),
    ("Share to Minis", "Share to Fin"),
    ("Minis Files", "Fin Files"),
]

# Tokens that contain `Minis` but MUST survive the generic rename.
# Every key is substituted by a placeholder before the generic pass and
# restored afterwards.
PROTECTED_TOKENS: list[str] = [
    # Mistral model family
    "Ministral",
    # OSC marker + parsers
    "MinisOpenURLBroker", "MinisOpenUrlBroker", "MinisOpenURLHandler",
    "MinisOpenURL", "MinisUrlMarker", "MinisURLMarker", "MinisURLSchemeHandler",
    "MinisURLPathDecoding", "MinisURL", "MinisScheme",
    # minis:// media/file plumbing
    "MinisMediaViews", "MinisMediaCache", "MinisMedia", "MinisImageFetcher",
    "MinisImageProvider", "MinisImageSizes_v1", "MinisImage", "MinisFileChipView",
    "MinisVideoFullscreenPlayer", "MinisFullscreenVideoPlayer", "MinisVideoPlayerView",
    "MinisVideoBlock", "MinisAudioPreviewView", "MinisAudioPlayerView", "MinisAudioBlock",
    "MinisImageFilePreviewView", "MinisImageBlock", "MinisImageView",
    "MinisLinkPreviewView", "MinisMarkdownPreviewView", "MinisHTMLPreviewView",
    "MinisDocumentPreviewView", "MinisTextPreviewView", "MinisTextView",
    "MinisSafariView", "MinisAVPlayerLayerView",
    "MinisMarkdownView", "MinisFsRouter", "MinisSymlink",
    # minis-config wire contract + storage dirs
    "MinisConfigPermissionStore", "MinisConfig", "MinisChat",
    'appendingPathComponent("MinisFileProvider"', "MinisFileProvider/",
    "MinisShared", "MinisSoulMdChanged",
    # upstream repos / org + issue namespace (OpenMinis#163 etc.)
    "MinisSkills", "AwesomeMinis", "OpenMinis",
    # camelCase helpers around minis:// URLs / paths (lowercase-m prefix ones are
    # untouched anyway; these are the mid-word capital-M variants)
    "linuxPathToMinisURL", "resolveMinisFileURLCached", "resolveMinisFileURL",
    "resolveMinisFileURLForNativeText", "resolveMinisFileURLForAutoPlay",
    "resolveMinisURL", "ResolveMinisURL", "resolveMinisPath", "isMinisURL",
    "handleMinisURLTap", "openMinisURL", "OpenMinisURLAction", "OpenMinisURLKey",
    "encodeRawMinisURL", "sharedMinisSchemeHandler", "offloadMinisURL",
    "interceptMinisURL", "isPersistentMinisPath", "mountMinisSubdir", "mountMinis",
    "ensureMinisSymlinks", "snapshotMinisFiles", "missingMinisFileName",
    "currentMinisSize", "_currentMinisSize", "pendingMinisOpenUrl",
    "handleMinisConfigExec", "executeCanAccessMinisDirectories",
    "testLinuxMinisAdmitted", "cleanupMinis", "varMinis", "dataVarMinis",
    "openInMinis",
    # native error domains (protocol-ish; harmless either way but keep stable)
    "MinisHealthKitOffload", "MinisDebugOffload", "MinisSpeech",
    "MinisDebugVoiceMicTap",
]
# Sort longest-first so e.g. MinisOpenURLBroker is matched before MinisOpenURL.
PROTECTED_TOKENS.sort(key=len, reverse=True)

# Files/dirs that must never be touched.
SKIP_DIRS = {".git", "deps", "node_modules", "build", ".gradle", ".idea"}
SKIP_SUFFIXES = {
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico", ".icns", ".pdf", ".zip",
    ".tar", ".gz", ".jar", ".aar", ".so", ".a", ".dylib", ".ttf", ".otf",
    ".woff", ".woff2", ".mp3", ".wav", ".m4a", ".mp4", ".mov", ".bin", ".dat",
    ".car", ".xcuserstate",
}
# The protocol vocabulary in the rootfs must stay byte-identical.
SKIP_PATH_PARTS = ("default_mount",)
# Upstream-history markdown stays as documentation of where the code came from.
SKIP_FILES = {"rename_to_fin.py", ".gitmodules"}
SKIP_SUFFIXES |= {".md"}

GENERIC_MINIS = re.compile(r"Minis")


def tracked_files() -> list[Path]:
    out = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT)
    return [ROOT / p for p in out.decode().split("\0") if p]


def should_skip(p: Path) -> bool:
    rel = p.relative_to(ROOT)
    if rel.parts and rel.parts[0] in SKIP_DIRS:
        return True
    if any(part in SKIP_PATH_PARTS for part in rel.parts):
        return True
    if p.suffix.lower() in SKIP_SUFFIXES:
        return True
    if p.name in SKIP_FILES:
        return True
    return False


def transform(text: str) -> str:
    for old, new in ORDERED_LITERALS:
        text = text.replace(old, new)
    # Shield protected tokens.
    shields: dict[str, str] = {}
    for i, tok in enumerate(PROTECTED_TOKENS):
        if tok in text:
            ph = f"\u0001PROT{i}\u0001"
            shields[ph] = tok
            text = text.replace(tok, ph)
    text = GENERIC_MINIS.sub("Fin", text)
    for ph, tok in shields.items():
        text = text.replace(ph, tok)
    return text


def main() -> int:
    changed = 0
    for p in tracked_files():
        if not p.is_file() or should_skip(p):
            continue
        try:
            raw = p.read_bytes()
        except OSError:
            continue
        try:
            text = raw.decode("utf-8")
        except UnicodeDecodeError:
            continue
        new = transform(text)
        if new != text:
            p.write_bytes(new.encode("utf-8"))
            changed += 1
    print(f"rewrote {changed} files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
