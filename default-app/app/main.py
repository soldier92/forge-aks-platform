import os

from fastapi import FastAPI, Response


app = FastAPI(title="Forge Default App")


def metadata() -> dict[str, str]:
    return {
        "team_name": os.getenv("TEAM_NAME", "unknown"),
        "environment": os.getenv("ENVIRONMENT", "dev"),
        "app_version": os.getenv("APP_VERSION", "0.1.0"),
    }


@app.get("/")
def root():
    return {"message": "Default FastAPI starter app", **metadata()}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/ready")
def ready():
    return {"status": "ready"}


@app.get("/team-info")
def team_info():
    return metadata()


@app.get("/metrics")
def metrics():
    payload = [
        "# HELP app_info Static information about the default app",
        "# TYPE app_info gauge",
        f'app_info{{team_name="{metadata()["team_name"]}",environment="{metadata()["environment"]}",version="{metadata()["app_version"]}"}} 1',
    ]
    return Response(content="\n".join(payload) + "\n", media_type="text/plain")
