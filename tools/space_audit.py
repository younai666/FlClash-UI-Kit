"""Audit repository space footprint across categories, local caches, and Git tracking."""
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def get_dir_size_and_count(path):
    total = 0
    files = 0
    dirs = 0
    if not path.exists():
        return 0, 0, 0
    for p in path.rglob('*'):
        if p.is_file():
            try:
                total += p.stat().st_size
                files += 1
            except Exception:
                pass
        elif p.is_dir():
            dirs += 1
    return total, files, dirs


def main():
    total_ws_bytes, total_ws_files, total_ws_dirs = get_dir_size_and_count(ROOT)

    proc = subprocess.run(['git', 'ls-files', '-z'], cwd=ROOT, stdout=subprocess.PIPE, check=True)
    tracked_paths = [f for f in proc.stdout.decode('utf-8', errors='ignore').split('\0') if f]
    tracked_bytes = sum((ROOT / f).stat().st_size for f in tracked_paths if (ROOT / f).is_file())

    git_bytes, git_files, _ = get_dir_size_and_count(ROOT / '.git')
    upstream_bytes, upstream_files, _ = get_dir_size_and_count(ROOT / 'source/upstream')
    upstream_lock_bytes = (ROOT / 'source/upstream-lock.json').stat().st_size if (ROOT / 'source/upstream-lock.json').exists() else 0

    local_bytes, local_files, _ = get_dir_size_and_count(ROOT / '.local')
    local_avd_bytes, local_avd_files, _ = get_dir_size_and_count(ROOT / '.local/android-avd')
    local_tc_bytes, local_tc_files, _ = get_dir_size_and_count(ROOT / '.local/toolchains')

    build_dirs = [p for p in ROOT.rglob('*') if p.is_dir() and not str(p).startswith(str(ROOT / '.git')) and p.name in ('build', 'target', 'ephemeral')]
    build_bytes = sum(get_dir_size_and_count(b)[0] for b in build_dirs)
    build_files = sum(get_dir_size_and_count(b)[1] for b in build_dirs)

    dart_tool_dirs = [p for p in ROOT.rglob('*') if p.is_dir() and not str(p).startswith(str(ROOT / '.git')) and p.name == '.dart_tool']
    dart_tool_bytes = sum(get_dir_size_and_count(dt)[0] for b in dart_tool_dirs for dt in [b])
    dart_tool_files = sum(get_dir_size_and_count(dt)[1] for b in dart_tool_dirs for dt in [b])

    def mb(b):
        return f"{b / (1024 * 1024):.2f} MB"

    def gb(b):
        return f"{b / (1024 * 1024 * 1024):.2f} GB"

    report = {
        "workspace_total": {"bytes": total_ws_bytes, "mb": mb(total_ws_bytes), "gb": gb(total_ws_bytes), "files": total_ws_files, "dirs": total_ws_dirs},
        "git_tracked_footprint": {"bytes": tracked_bytes, "mb": mb(tracked_bytes), "files": len(tracked_paths)},
        "git_history": {"bytes": git_bytes, "mb": mb(git_bytes), "files": git_files},
        "upstream_snapshots": {"bytes": upstream_bytes + upstream_lock_bytes, "mb": mb(upstream_bytes + upstream_lock_bytes), "files": upstream_files + 1},
        "build_artifacts": {"bytes": build_bytes, "mb": mb(build_bytes), "files": build_files, "dirs_count": len(build_dirs)},
        "dart_tool_caches": {"bytes": dart_tool_bytes, "mb": mb(dart_tool_bytes), "files": dart_tool_files, "dirs_count": len(dart_tool_dirs)},
        "local_caches": {
            "total_bytes": local_bytes,
            "total_mb": mb(local_bytes),
            "android_avd_mb": mb(local_avd_bytes),
            "rust_toolchains_mb": mb(local_tc_bytes),
            "other_logs_mb": mb(local_bytes - local_avd_bytes - local_tc_bytes),
        },
    }

    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
