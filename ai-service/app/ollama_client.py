import httpx

from .config import CHAT_MODEL, EMBED_MODEL, OLLAMA_BASE_URL


async def chat_completion(system_prompt: str, messages: list[dict], temperature: float = 0.8) -> str:
    """Calls the local Ollama chat endpoint. Raises httpx.HTTPStatusError if Ollama is unreachable
    or the model isn't pulled — callers should surface a clean error, not a stack trace."""
    payload_messages = [{"role": "system", "content": system_prompt}] + messages
    async with httpx.AsyncClient(timeout=120.0) as client:
        resp = await client.post(
            f"{OLLAMA_BASE_URL}/api/chat",
            json={
                "model": CHAT_MODEL,
                "messages": payload_messages,
                "stream": False,
                "options": {"temperature": temperature},
            },
        )
        resp.raise_for_status()
        data = resp.json()
        return data["message"]["content"].strip()


async def embed_text(text: str) -> list[float]:
    async with httpx.AsyncClient(timeout=60.0) as client:
        resp = await client.post(
            f"{OLLAMA_BASE_URL}/api/embeddings",
            json={"model": EMBED_MODEL, "prompt": text},
        )
        resp.raise_for_status()
        data = resp.json()
        return data["embedding"]
