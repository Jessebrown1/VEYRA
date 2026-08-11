"""Provider dispatcher — every router imports chat_completion/embed_text from
here rather than from a specific provider module, so MODEL_PROVIDER is the
only thing that needs to change to swap providers (local Ollama for dev,
Gemini's free tier for a hosted deployment like Render)."""

from . import gemini_client, ollama_client
from .config import MODEL_PROVIDER


async def chat_completion(system_prompt: str, messages: list[dict], temperature: float = 0.8) -> str:
    if MODEL_PROVIDER == "gemini":
        return await gemini_client.chat_completion(system_prompt, messages, temperature)
    return await ollama_client.chat_completion(system_prompt, messages, temperature)


async def embed_text(text: str) -> list[float]:
    if MODEL_PROVIDER == "gemini":
        return await gemini_client.embed_text(text)
    return await ollama_client.embed_text(text)
