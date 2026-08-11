import httpx

from .config import GROQ_API_KEY, GROQ_CHAT_MODEL

BASE_URL = "https://api.groq.com/openai/v1/chat/completions"


async def chat_completion(system_prompt: str, messages: list[dict], temperature: float = 0.8) -> str:
    """Same signature as gemini_client/ollama_client.chat_completion — Groq's
    API is OpenAI-compatible, so this is a plain chat-completions call rather
    than Gemini's contents/parts shape."""
    payload_messages = [{"role": "system", "content": system_prompt}] + [
        {"role": m["role"], "content": m["content"]} for m in messages
    ]

    async with httpx.AsyncClient(timeout=60.0) as client:
        resp = await client.post(
            BASE_URL,
            headers={"Authorization": f"Bearer {GROQ_API_KEY}"},
            json={
                "model": GROQ_CHAT_MODEL,
                "messages": payload_messages,
                "temperature": temperature,
            },
        )
        resp.raise_for_status()
        data = resp.json()
        return data["choices"][0]["message"]["content"].strip()
