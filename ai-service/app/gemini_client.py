import asyncio
from typing import Optional

import httpx

from .config import (
    GEMINI_API_KEY,
    GEMINI_CHAT_MODEL,
    GEMINI_EMBED_DIMENSIONS,
    GEMINI_EMBED_MODEL,
)

BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models"

MAX_RETRIES = 3
BACKOFF_SECONDS = 1.5


def _to_gemini_role(sender_role: str) -> str:
    # Gemini uses "model" where OpenAI-style APIs use "assistant".
    return "model" if sender_role == "assistant" else "user"


async def _post_with_retry(client: httpx.AsyncClient, url: str, **kwargs) -> httpx.Response:
    """Gemini's free tier has a low per-minute request cap — a burst of chat
    traffic can trip a transient 429 that clears within a couple of seconds.
    Retry those with backoff instead of failing the user's message outright;
    any other status is raised immediately."""
    last_exc: Optional[Exception] = None
    for attempt in range(MAX_RETRIES + 1):
        resp = await client.post(url, **kwargs)
        if resp.status_code != 429:
            resp.raise_for_status()
            return resp
        last_exc = httpx.HTTPStatusError(
            f"429 Too Many Requests for url '{resp.url}'", request=resp.request, response=resp
        )
        if attempt < MAX_RETRIES:
            await asyncio.sleep(BACKOFF_SECONDS * (2**attempt))
    assert last_exc is not None
    raise last_exc


async def chat_completion(system_prompt: str, messages: list[dict], temperature: float = 0.8) -> str:
    """Same signature as ollama_client.chat_completion — the AIService abstraction
    at the call sites doesn't need to know which provider is behind it."""
    contents = [
        {"role": _to_gemini_role(m["role"]), "parts": [{"text": m["content"]}]} for m in messages
    ]

    async with httpx.AsyncClient(timeout=60.0) as client:
        resp = await _post_with_retry(
            client,
            f"{BASE_URL}/{GEMINI_CHAT_MODEL}:generateContent",
            params={"key": GEMINI_API_KEY},
            json={
                "contents": contents,
                "systemInstruction": {"parts": [{"text": system_prompt}]},
                "generationConfig": {"temperature": temperature},
            },
        )
        data = resp.json()
        return data["candidates"][0]["content"]["parts"][0]["text"].strip()


async def embed_text(text: str) -> list[float]:
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await _post_with_retry(
            client,
            f"{BASE_URL}/{GEMINI_EMBED_MODEL}:embedContent",
            params={"key": GEMINI_API_KEY},
            json={
                "content": {"parts": [{"text": text}]},
                "output_dimensionality": GEMINI_EMBED_DIMENSIONS,
            },
        )
        data = resp.json()
        return data["embedding"]["values"]
