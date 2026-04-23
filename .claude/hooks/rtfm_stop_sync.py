#!/usr/bin/env python3
"""RTFM Stop hook — final sync to catch files created/modified this turn.

The UserPromptSubmit hook syncs every 30s, but the last Write/Edit may
happen right before the agent stops. This hook runs a final sync to
ensure everything is indexed.
"""
import json, os, sys, time
from pathlib import Path

# Resolve project root from $CLAUDE_PROJECT_DIR so the hook works regardless
# of the agent's current working directory.
PROJECT_ROOT = Path(os.environ.get("CLAUDE_PROJECT_DIR") or Path(__file__).resolve().parents[2])

def _log(msg):
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

    if not sources:
        sources = [{"path": str(PROJECT_ROOT), "corpus": default_corpus}]

    _log(f"stop-sync starting {len(sources)} source(s)")
    t0 = time.time()
    try:
        from rtfm.core.library import Library
        from rtfm.core.sync import sync

        lib = Library(str(db_path))
        total_added = total_modified = 0
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
        lib.close()
        elapsed = time.time() - t0
        _log(f"stop-sync done +{total_added} ~{total_modified} time={elapsed:.2f}s")
    except Exception as e:
        _log(f"stop-sync ERROR: {e}")


if __name__ == "__main__":
    main()
