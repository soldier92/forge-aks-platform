import enum
from datetime import datetime

from sqlalchemy import DateTime, Enum, Integer, Text
from sqlalchemy.orm import Mapped, mapped_column

from .database import Base


class RequestStatus(str, enum.Enum):
    PENDING_APPROVAL = "PENDING_APPROVAL"
    NEEDS_CHANGES = "NEEDS_CHANGES"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"
    PROVISIONING = "PROVISIONING"
    DEPLOYED = "DEPLOYED"
    FAILED = "FAILED"


class EnvironmentRequest(Base):
    __tablename__ = "environment_requests"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    team_name: Mapped[str] = mapped_column(Text, nullable=False)
    environment: Mapped[str] = mapped_column(Text, nullable=False)
    app_type: Mapped[str] = mapped_column(Text, nullable=False)
    requested_cpu: Mapped[str] = mapped_column(Text, nullable=False)
    requested_memory: Mapped[str] = mapped_column(Text, nullable=False)
    image: Mapped[str] = mapped_column(Text, nullable=False)
    requested_by: Mapped[str] = mapped_column(Text, nullable=False)
    supervisor_email: Mapped[str] = mapped_column(Text, nullable=False)
    business_justification: Mapped[str] = mapped_column(Text, nullable=False)
    status: Mapped[RequestStatus] = mapped_column(
        Enum(RequestStatus), default=RequestStatus.PENDING_APPROVAL, nullable=False
    )
    admin_comment: Mapped[str] = mapped_column(Text, default="", nullable=False)
    ai_recommendation: Mapped[str] = mapped_column(Text, default="", nullable=False)
    deployment_log: Mapped[str] = mapped_column(Text, default="", nullable=False)
    error_message: Mapped[str] = mapped_column(Text, default="", nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    deployed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
