from fastapi import APIRouter
from pydantic import BaseModel

from ..ollama_client import embed_text

router = APIRouter(prefix="/embed", tags=["embed"])


class EmbedRequest(BaseModel):
    text: str


class EmbedResponse(BaseModel):
    embedding: list[float]


@router.post("", response_model=EmbedResponse)
async def embed(req: EmbedRequest) -> EmbedResponse:
    vector = await embed_text(req.text)
    return EmbedResponse(embedding=vector)
