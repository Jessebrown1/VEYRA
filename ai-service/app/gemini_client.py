import httpx

from .config import (
    GEMINI_API_KEY,
    GEMINI_CHAT_MODEL,
    GEMINI_EMBED_DIMENSIONS,
    GEMINI_EMBED_MODEL,
)

BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models"


def _to_gemini_role(sender_role: str) -> str:
    # Gemini uses "model" where OpenAI-style APIs use "assistant".
    return "model" if sender_role == "assistant" else "user"


async def chat_completion(system_prompt: str, messages: list[dict], temperature: float = 0.8) -> str:
    """Same signature as ollama_client.chat_completion — the AIService abstraction
    at the call sites doesn't need to know which provider is behind it."""
    contents = [
        {"role": _to_gemini_role(m["role"]), "parts": [{"text": m["content"]}]} for m in messages
    ]

    async with httpx.AsyncClient(timeout=60.0) as client:
        resp = await client.post(
            f"{BASE_URL}/{GEMINI_CHAT_MODEL}:generateContent",
            params={"key": GEMINI_API_KEY},
            json={
                "contents": contents,
                "systemInstruction": {"parts": [{"text": system_prompt}]},
                "generationConfig": {"temperature": temperature},
            },
        )
        resp.raise_for_status()
        data = resp.json()
        return data["candidates"][0]["content"]["parts"][0]["text"].strip()


async def embed_text(text: str) -> list[float]:
    async with httpx.AsyncClient(timeout=30.0) as client:
        resp = await client.post(
            f"{BASE_URL}/{GEMINI_EMBED_MODEL}:embedContent",
            params={"key": GEMINI_API_KEY},
            json={
                "content": {"parts": [{"text": text}]},
                "output_dimensionality": GEMINI_EMBED_DIMENSIONS,
            },
        )
        resp.raise_for_status()
        data = resp.json()
        return data["embedding"]["values"]
