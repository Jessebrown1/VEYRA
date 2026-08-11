import httpx
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import GEMINI_API_KEY
from .routers import embed, generate, memory

app = FastAPI(title="VEYRA AI Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(generate.router)
app.include_router(memory.router)
app.include_router(embed.router)


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}


@app.get("/_debug/models")
async def debug_models() -> dict:
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.get(
            "https://generativelanguage.googleapis.com/v1beta/models",
            params={"key": GEMINI_API_KEY},
        )
        data = resp.json()
        models = [
            {"name": m.get("name"), "methods": m.get("supportedGenerationMethods")}
            for m in data.get("models", [])
        ]
        return {"status": resp.status_code, "models": models}


@app.get("/_debug/try/{model_name}")
async def debug_try(model_name: str) -> dict:
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.post(
            f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent",
            params={"key": GEMINI_API_KEY},
            json={"contents": [{"role": "user", "parts": [{"text": "say hi"}]}]},
        )
        return {"status": resp.status_code, "body": resp.text[:2000]}
