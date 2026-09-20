#!/usr/bin/env python3
"""Regenerate web/dashboard_data.js from dashboard/real_kpis.json."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "dashboard" / "real_kpis.json"
OUT = Path(__file__).resolve().parent / "dashboard_data.js"


def read_json(path: Path):
    for enc in ("utf-8-sig", "utf-16", "utf-16-le"):
        try:
            return json.loads(path.read_text(encoding=enc))
        except (UnicodeDecodeError, json.JSONDecodeError):
            continue
    raise SystemExit(f"Could not decode {path}")


def main() -> None:
    if not SRC.exists():
        raise SystemExit(f"Source not found: {SRC}")
    data = read_json(SRC)
    js = "// Auto-generated — do not edit by hand.\nconst dashboard_data = " + json.dumps(data, ensure_ascii=False, indent=2) + ";\n"
    OUT.write_text(js, encoding="utf-8")
    print(f"Wrote {OUT.relative_to(ROOT)} ({len(js):,} bytes)")


if __name__ == "__main__":
    main()