from __future__ import annotations

import os
import re
import shutil
import subprocess
import tempfile
from datetime import datetime
from pathlib import Path

from jinja2 import Environment, FileSystemLoader

from .models import EnvironmentRequest, RequestStatus


ROOT_DIR = Path(__file__).resolve().parents[2]
TEMPLATE_DIR = ROOT_DIR / "k8s-templates"


def _safe_name(value: str) -> str:
    cleaned = re.sub(r"[^a-z0-9-]", "-", value.strip().lower())
    cleaned = re.sub(r"-{2,}", "-", cleaned).strip("-")
    return cleaned or "team"


def namespace_for(request: EnvironmentRequest) -> str:
    return f"team-{_safe_name(request.team_name)}-{_safe_name(request.environment)}"


def _render_templates(context: dict) -> dict[str, str]:
    env = Environment(loader=FileSystemLoader(str(TEMPLATE_DIR)), autoescape=False)
    rendered: dict[str, str] = {}
    for template_name in sorted(TEMPLATE_DIR.glob("*.j2")):
        template = env.get_template(template_name.name)
        rendered[template_name.stem] = template.render(**context)
    return rendered


def provision_request(request: EnvironmentRequest) -> tuple[RequestStatus, str, str]:
    namespace = namespace_for(request)
    image = request.image or os.getenv("DEFAULT_IMAGE", "ghcr.io/example/default-app:latest")
    context = {
        "namespace": namespace,
        "team_name": request.team_name,
        "environment": request.environment,
        "app_name": "starter-api",
        "service_account_name": "starter-api-sa",
        "image": image,
        "requested_cpu": request.requested_cpu,
        "requested_memory": request.requested_memory,
        "app_version": datetime.utcnow().strftime("%Y%m%d%H%M%S"),
    }
    manifests = _render_templates(context)
    log_lines = [f"Namespace: {namespace}", f"Image: {image}"]

    if os.getenv("DRY_RUN", "true").lower() == "true":
        for name, manifest in manifests.items():
            log_lines.append(f"\n--- {name} ---\n{manifest}")
        return RequestStatus.DEPLOYED, "\n".join(log_lines), ""

    kubectl = shutil.which("kubectl")
    if not kubectl:
        return RequestStatus.FAILED, "\n".join(log_lines), "kubectl was not found on PATH."

    try:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp_path = Path(tmp_dir)
            for name, manifest in manifests.items():
                (tmp_path / f"{name}.yaml").write_text(manifest, encoding="utf-8")

            result = subprocess.run(
                [kubectl, "apply", "-f", str(tmp_path)],
                capture_output=True,
                text=True,
                check=False,
            )
            log_lines.append(result.stdout.strip())
            if result.stderr.strip():
                log_lines.append(result.stderr.strip())

            if result.returncode != 0:
                return RequestStatus.FAILED, "\n".join(log_lines), "kubectl apply failed."
    except Exception as exc:
        return RequestStatus.FAILED, "\n".join(log_lines), str(exc)

    return RequestStatus.DEPLOYED, "\n".join(log_lines), ""
