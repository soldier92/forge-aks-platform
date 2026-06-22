from __future__ import annotations

import json
import os
import re
from datetime import datetime
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

from .models import EnvironmentRequest, RequestStatus


DEFAULT_WORKFLOW_FILE = "requestedenvironment-infra.yml"
DEFAULT_WORKFLOW_REF = "main"
DEFAULT_DEPLOYMENT_TYPE = "aks-namespace-app"


def _safe_name(value: str) -> str:
    cleaned = re.sub(r"[^a-z0-9-]", "-", value.strip().lower())
    cleaned = re.sub(r"-{2,}", "-", cleaned).strip("-")
    return cleaned or "team"


def namespace_for(request: EnvironmentRequest) -> str:
    return f"team-{_safe_name(request.team_name)}-{_safe_name(request.environment)}"


def _github_api_url() -> str:
    return os.getenv("GITHUB_API_URL", "https://api.github.com").rstrip("/")


def _github_repository() -> str:
    return os.getenv("GITHUB_REPOSITORY", "").strip()


def _github_workflow_file() -> str:
    return os.getenv("GITHUB_WORKFLOW_FILE", DEFAULT_WORKFLOW_FILE).strip()


def _github_workflow_ref() -> str:
    return os.getenv("GITHUB_WORKFLOW_REF", DEFAULT_WORKFLOW_REF).strip()


def _github_token() -> str:
    return os.getenv("AKS_TEAM_TOKEN", "").strip()


def _dispatch_workflow(request: EnvironmentRequest) -> str:
    repository = _github_repository()
    workflow_file = _github_workflow_file()
    workflow_ref = _github_workflow_ref()
    token = _github_token()

    missing = [
        name
        for name, value in {
            "GITHUB_REPOSITORY": repository,
            "GITHUB_WORKFLOW_FILE": workflow_file,
            "GITHUB_WORKFLOW_REF": workflow_ref,
            "AKS_TEAM_TOKEN": token,
        }.items()
        if not value
    ]
    if missing:
        raise RuntimeError(f"Missing required GitHub dispatch settings: {', '.join(missing)}")

    app_version = f"portal-request-{request.id}-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}"
    image = request.image or os.getenv("DEFAULT_IMAGE", "")
    deployment_type = os.getenv("REQUESTED_ENVIRONMENT_DEPLOYMENT_TYPE", DEFAULT_DEPLOYMENT_TYPE)
    payload = {
        "ref": workflow_ref,
        "inputs": {
            "team_name": request.team_name,
            "requested_environment": request.environment,
            "requested_cpu": request.requested_cpu,
            "requested_memory": request.requested_memory,
            "requested_image": image,
            "app_version": app_version,
            "deployment_type": deployment_type,
            "action": "apply",
        },
    }

    api_request = Request(
        f"{_github_api_url()}/repos/{repository}/actions/workflows/{workflow_file}/dispatches",
        data=json.dumps(payload).encode("utf-8"),
        method="POST",
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "User-Agent": "forge-management-portal",
            "X-GitHub-Api-Version": "2022-11-28",
        },
    )

    try:
        with urlopen(api_request, timeout=20) as response:
            if response.status != 204:
                raise RuntimeError(f"GitHub dispatch returned HTTP {response.status}")
    except HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"GitHub dispatch failed with HTTP {exc.code}: {detail}") from exc
    except URLError as exc:
        raise RuntimeError(f"GitHub dispatch failed: {exc.reason}") from exc

    workflow_url = f"https://github.com/{repository}/actions/workflows/{workflow_file}"
    return "\n".join(
        [
            "GitHub Actions workflow dispatch accepted.",
            f"Workflow: {workflow_url}",
            f"Ref: {workflow_ref}",
            f"Team namespace: {namespace_for(request)}",
            f"Deployment type: {deployment_type}",
            f"App version: {app_version}",
            f"Image: {image}",
        ]
    )


def provision_request(request: EnvironmentRequest) -> tuple[RequestStatus, str, str]:
    if os.getenv("DRY_RUN", "true").lower() == "true":
        log_lines = [
            "DRY_RUN is enabled; GitHub Actions workflow was not dispatched.",
            f"Workflow: {_github_workflow_file()}",
            f"Ref: {_github_workflow_ref()}",
            f"Team namespace: {namespace_for(request)}",
            f"Deployment type: {os.getenv('REQUESTED_ENVIRONMENT_DEPLOYMENT_TYPE', DEFAULT_DEPLOYMENT_TYPE)}",
        ]
        return RequestStatus.APPROVED, "\n".join(log_lines), ""

    try:
        deployment_log = _dispatch_workflow(request)
    except Exception as exc:
        return RequestStatus.FAILED, "", str(exc)

    return RequestStatus.PROVISIONING, deployment_log, ""
