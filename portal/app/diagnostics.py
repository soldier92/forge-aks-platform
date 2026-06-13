from __future__ import annotations

import os
import shutil


def gather_runtime_diagnostics() -> dict[str, str]:
    return {
        "dry_run": os.getenv("DRY_RUN", "true"),
        "default_image": os.getenv("DEFAULT_IMAGE", "ghcr.io/example/default-app:latest"),
        "kubectl_available": "yes" if shutil.which("kubectl") else "no",
    }
