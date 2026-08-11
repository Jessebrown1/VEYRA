"""Provider dispatcher — every router imports chat_completion/embed_text from
here rather than from a specific provider module, so MODEL_PROVIDER is the
only thing that needs to change to swap providers (local Ollama for dev,
Groq or Gemini for a hosted deployment like Render)."""

from . import gemini_client, groq_client, ollama_client
from .config import MODEL_PROVIDER


async def chat_completion(system_prompt: str, messages: list[dict], temperature: float = 0.8) -> str:
    if MODEL_PROVIDER == "groq":
        return await groq_client.chat_completion(system_prompt, messages, temperature)
    if MODEL_PROVIDER == "gemini":
        return await gemini_client.chat_completion(system_prompt, messages, temperature)
    return await ollama_client.chat_completion(system_prompt, messages, temperature)


async def embed_text(text: str) -> list[float]:
    # Groq has no embeddings endpoint, so embeddings ride on Gemini even
    # when Groq is the chat provider.
    if MODEL_PROVIDER in ("groq", "gemini"):
        return await gemini_client.embed_text(text)
    return await ollama_client.embed_text(text)
