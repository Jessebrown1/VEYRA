import os

from dotenv import load_dotenv

load_dotenv()

# "ollama" for local dev (default, free, runs on this machine), "groq" for a
# hosted deployment using Groq's much more generous free-tier rate limits, or
# "gemini" as a fallback hosted option. Embeddings always come from Gemini
# (or Ollama locally) since Groq doesn't offer an embeddings endpoint.
MODEL_PROVIDER = os.getenv("MODEL_PROVIDER", "ollama")

OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
CHAT_MODEL = os.getenv("CHAT_MODEL", "llama3.2:3b")
EMBED_MODEL = os.getenv("EMBED_MODEL", "nomic-embed-text")

GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")
GROQ_CHAT_MODEL = os.getenv("GROQ_CHAT_MODEL", "llama-3.3-70b-versatile")

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GEMINI_CHAT_MODEL = os.getenv("GEMINI_CHAT_MODEL", "gemini-flash-latest")
GEMINI_EMBED_MODEL = os.getenv("GEMINI_EMBED_MODEL", "gemini-embedding-2")
# Matches the Postgres `vector(768)` column so no migration is needed when
# switching providers — Gemini's embedding model supports truncating its
# output to this size via output_dimensionality.
GEMINI_EMBED_DIMENSIONS = int(os.getenv("GEMINI_EMBED_DIMENSIONS", "768"))
