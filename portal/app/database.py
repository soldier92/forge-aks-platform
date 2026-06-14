import os
from pathlib import Path

from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker


BASE_DIR = Path(__file__).resolve().parent.parent
DEFAULT_DB_PATH = BASE_DIR / "controlplane.db"
DATABASE_URL = os.getenv("DATABASE_URL", f"sqlite:///{os.getenv('CONTROLPLANE_DB_PATH', DEFAULT_DB_PATH)}")

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    from . import models

    models.Base.metadata.create_all(bind=engine)
