#!/usr/bin/env python3
"""RTFM UserPromptSubmit hook — fast incremental FTS sync.

Runs on every prompt:
1. Reads corpus from .rtfm/config.json (set during init)
2. Quick incremental sync (FTS only, no embeddings) — typically <2s
3. Embeddings are handled by the MCP server in background (model stays loaded)
"""
import json, os, sys, time
from pathlib import Path

STALE_SECONDS = 30  # Re-sync at most every 30 seconds

# Resolve project root from $CLAUDE_PROJECT_DIR so the hook works regardless
# of the agent's current working directory.
PROJECT_ROOT = Path(os.environ.get("CLAUDE_PROJECT_DIR") or Path(__file__).resolve().parents[2])

def _log(msg):
    """Append to .rtfm/rtfm.log (inline, no imports)."""
    try:
        ts = time.strftime("%H:%M:%S")
        log_path = PROJECT_ROOT / ".rtfm" / "rtfm.log"
        with open(log_path, "a") as f:
            f.write(f"[{ts}]       hook | {msg}\n")
    except Exception:
        pass

def main():
    rtfm_dir = PROJECT_ROOT / ".rtfm"
    if not rtfm_dir.exists():
        return

    db_path = rtfm_dir / "library.db"
    if not db_path.exists():
        return

    # Throttle: don't sync more than once every STALE_SECONDS
    stamp_file = rtfm_dir / ".sync_ts"
    now = time.time()
    if stamp_file.exists():
        try:
            last = float(stamp_file.read_text().strip())
            if now - last < STALE_SECONDS:
                _log(f"throttled (last sync {now - last:.0f}s ago)")
                return
        except (ValueError, OSError):
            pass

    # Read sources from config
    config_path = rtfm_dir / "config.json"
    sources = []
    default_corpus = "default"
    if config_path.exists():
        try:
            cfg = json.loads(config_path.read_text())
            sources = cfg.get("sources", [])
            default_corpus = cfg.get("corpus", "default")
        except Exception:
            pass

    # Fallback: no sources configured, sync project root with default corpus
    if not sources:
        sources = [{"path": str(PROJECT_ROOT), "corpus": default_corpus}]

    # Quick incremental sync for each source (no embeddings — fast)
    _log(f"sync starting {len(sources)} source(s)")
    t0 = time.time()
    try:
        from rtfm.core.library import Library
        from rtfm.core.sync import sync

        lib = Library(str(db_path))
        total_added = total_modified = total_removed = 0
        for src in sources:
            src_path = Path(src.get("path", ".")).resolve()
            src_corpus = src.get("corpus", default_corpus)
            ext_set = None
            if src.get("extensions"):
                ext_set = {e.strip() if e.strip().startswith(".") else f".{e.strip()}"
                           for e in src["extensions"].split(",")}
            result = sync(
                library=lib,
                root=src_path,
                corpus=src_corpus,
                extensions=ext_set,
                generate_embeddings=False,
            )
            total_added += result.added
            total_modified += result.modified
            total_removed += result.removed
        lib.close()
        stamp_file.write_text(str(now))
        elapsed = time.time() - t0
        _log(f"sync done +{total_added} ~{total_modified} -{total_removed} time={elapsed:.2f}s ({len(sources)} sources)")
    except Exception as e:
        _log(f"sync ERROR: {e}")


if __name__ == "__main__":
    main()
