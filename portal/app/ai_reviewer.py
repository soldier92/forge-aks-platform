from __future__ import annotations

from dataclasses import dataclass


@dataclass
class ReviewResult:
    recommendation: str
    risk_level: str
    summary: str
    prompt: str


def _cpu_value(raw_value: str) -> float:
    value = raw_value.strip().lower().replace("m", "")
    try:
        if raw_value.strip().lower().endswith("m"):
            return float(value) / 1000
        return float(value)
    except ValueError:
        return 0.0


def _memory_gib(raw_value: str) -> float:
    value = raw_value.strip().lower()
    try:
        if value.endswith("gi"):
            return float(value[:-2])
        if value.endswith("mi"):
            return float(value[:-2]) / 1024
        return float(value)
    except ValueError:
        return 0.0


def build_recommendation(payload: dict) -> ReviewResult:
    reasons: list[str] = []
    cpu = _cpu_value(payload["requested_cpu"])
    memory = _memory_gib(payload["requested_memory"])
    environment = payload["environment"].strip().lower()

    risk_level = "low"
    recommendation = "APPROVE"

    if cpu > 1 or memory > 1:
        risk_level = "medium"
        recommendation = "NEEDS_CHANGES"
        reasons.append("Requested capacity is above the default developer sandbox baseline.")

    if environment == "prod":
        risk_level = "high"
        recommendation = "REJECT"
        reasons.append("Production namespaces require a separate production-ready governance flow.")

    if "temporary" in payload["business_justification"].lower():
        reasons.append("The request appears time-bound and may benefit from an expiry policy.")

    if not reasons:
        reasons.append("The request fits the demo guardrails for non-production developer workloads.")

    summary = (
        f"Risk level: {risk_level}. Recommendation: {recommendation}. "
        + " ".join(reasons)
    )
    prompt = f"""Review this AKS environment request for an internal platform:
- Team: {payload['team_name']}
- Environment: {payload['environment']}
- App type: {payload['app_type']}
- CPU: {payload['requested_cpu']}
- Memory: {payload['requested_memory']}
- Image: {payload['image']}
- Requested by: {payload['requested_by']}
- Supervisor: {payload['supervisor_email']}
- Justification: {payload['business_justification']}

Please provide:
1. Risk assessment
2. Governance concerns
3. Cost concerns
4. Suggested approval decision
5. Extra platform controls to add later
"""
    return ReviewResult(
        recommendation=recommendation,
        risk_level=risk_level,
        summary=summary,
        prompt=prompt,
    )
