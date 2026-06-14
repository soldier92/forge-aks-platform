from __future__ import annotations

import os
from datetime import datetime
from pathlib import Path

from fastapi import Depends, FastAPI, Form, HTTPException, Query, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session

from .ai_reviewer import build_recommendation
from .database import get_db, init_db
from .diagnostics import gather_runtime_diagnostics
from .models import EnvironmentRequest, RequestStatus
from .provisioner import provision_request


app = FastAPI(title="Forge AKS Platform Control Plane")
templates = Jinja2Templates(directory=str(Path(__file__).parent / "templates"))


@app.on_event("startup")
def on_startup():
    init_db()


def _role(role: str = Query("developer")) -> str:
    if role not in {"developer", "admin"}:
        raise HTTPException(status_code=400, detail="Role must be developer or admin.")
    return role


@app.get("/", response_class=HTMLResponse)
def home(request: Request, role: str = Depends(_role), db: Session = Depends(get_db)):
    count = db.query(EnvironmentRequest).count()
    return templates.TemplateResponse(
        "index.html",
        {
            "request": request,
            "role": role,
            "request_count": count,
            "diagnostics": gather_runtime_diagnostics(),
        },
    )


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/request", response_class=HTMLResponse)
def request_form(request: Request, role: str = Depends(_role)):
    return templates.TemplateResponse(
        "request.html",
        {"request": request, "role": role, "default_image": os.getenv("DEFAULT_IMAGE", "")},
    )


@app.post("/request")
def submit_request(
    team_name: str = Form(...),
    environment: str = Form(...),
    app_type: str = Form(...),
    requested_cpu: str = Form(...),
    requested_memory: str = Form(...),
    image: str = Form(...),
    requested_by: str = Form(...),
    supervisor_email: str = Form(...),
    business_justification: str = Form(...),
    role: str = Depends(_role),
    db: Session = Depends(get_db),
):
    payload = {
        "team_name": team_name,
        "environment": environment,
        "app_type": app_type,
        "requested_cpu": requested_cpu,
        "requested_memory": requested_memory,
        "image": image,
        "requested_by": requested_by,
        "supervisor_email": supervisor_email,
        "business_justification": business_justification,
    }
    review = build_recommendation(payload)
    item = EnvironmentRequest(
        **payload,
        status=RequestStatus.PENDING_APPROVAL,
        ai_recommendation=f"{review.summary}\n\nPrompt for ChatGPT/Codex:\n{review.prompt}",
    )
    db.add(item)
    db.commit()
    db.refresh(item)
    return RedirectResponse(url=f"/requests/{item.id}?role={role}", status_code=303)


@app.get("/admin", response_class=HTMLResponse)
def admin_page(request: Request, role: str = Depends(_role), db: Session = Depends(get_db)):
    if role != "admin":
        raise HTTPException(status_code=403, detail="Admin role required.")
    items = db.query(EnvironmentRequest).order_by(EnvironmentRequest.created_at.desc()).all()
    return templates.TemplateResponse(
        "admin.html", {"request": request, "role": role, "items": items}
    )


@app.get("/requests/{request_id}", response_class=HTMLResponse)
def request_detail(
    request_id: int, request: Request, role: str = Depends(_role), db: Session = Depends(get_db)
):
    item = db.get(EnvironmentRequest, request_id)
    if not item:
        raise HTTPException(status_code=404, detail="Request not found.")
    return templates.TemplateResponse(
        "request_detail.html", {"request": request, "role": role, "item": item}
    )


@app.post("/admin/requests/{request_id}/review", response_class=HTMLResponse)
def review_request(
    request_id: int,
    request: Request,
    action: str = Form(...),
    admin_comment: str = Form(""),
    role: str = Depends(_role),
    db: Session = Depends(get_db),
):
    if role != "admin":
        raise HTTPException(status_code=403, detail="Admin role required.")

    item = db.get(EnvironmentRequest, request_id)
    if not item:
        raise HTTPException(status_code=404, detail="Request not found.")

    if action not in {status.value for status in RequestStatus}:
        raise HTTPException(status_code=400, detail="Unsupported action.")

    item.admin_comment = admin_comment
    item.reviewed_at = datetime.utcnow()

    selected = RequestStatus(action)
    if selected == RequestStatus.APPROVED:
        item.status = RequestStatus.PROVISIONING
        db.commit()
        db.refresh(item)

        final_status, deployment_log, error_message = provision_request(item)
        item.status = final_status
        item.deployment_log = deployment_log
        item.error_message = error_message
        if final_status == RequestStatus.DEPLOYED:
            item.deployed_at = datetime.utcnow()
    else:
        item.status = selected

    db.commit()
    db.refresh(item)
    return templates.TemplateResponse(
        "deployment_result.html", {"request": request, "role": role, "item": item}
    )
