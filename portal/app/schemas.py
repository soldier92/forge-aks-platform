from datetime import datetime

from pydantic import BaseModel, EmailStr, Field

from .models import RequestStatus


class EnvironmentRequestCreate(BaseModel):
    team_name: str = Field(min_length=2, max_length=40)
    environment: str
    app_type: str
    requested_cpu: str
    requested_memory: str
    image: str
    requested_by: str
    supervisor_email: EmailStr
    business_justification: str = Field(min_length=10)


class ReviewRequest(BaseModel):
    action: RequestStatus
    admin_comment: str = ""


class EnvironmentRequestRead(BaseModel):
    id: int
    team_name: str
    environment: str
    app_type: str
    requested_cpu: str
    requested_memory: str
    image: str
    requested_by: str
    supervisor_email: str
    business_justification: str
    status: RequestStatus
    admin_comment: str
    ai_recommendation: str
    deployment_log: str
    error_message: str
    created_at: datetime
    reviewed_at: datetime | None
    deployed_at: datetime | None

    class Config:
        from_attributes = True
