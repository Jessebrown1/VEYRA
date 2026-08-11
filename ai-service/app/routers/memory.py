import json
import re

from fastapi import APIRouter
from pydantic import BaseModel

from ..llm_client import chat_completion

router = APIRouter(prefix="/memory", tags=["memory"])

VALID_CATEGORIES = {
    "identity",
    "preferences",
    "interests",
    "relationships",
    "goals",
    "important_dates",
    "routines",
    "locations",
    "education",
    "work",
    "personal_facts",
    "conversation_context",
}

EXTRACTION_SYSTEM_PROMPT = (
    "You extract durable, worth-remembering facts about a user from one exchange of a conversation with "
    "their companion app. Only extract facts that would still be useful to know in future conversations "
    "(identity, preferences, interests, routines, important dates, goals, relationships, locations, "
    "education, work, personal facts). Do NOT extract small talk, one-off reactions, or anything about "
    "the companion itself.\n\n"
    "Respond with ONLY a JSON array (no prose, no markdown fences). Each item must have exactly these "
    "keys: category (one of: identity, preferences, interests, relationships, goals, important_dates, "
    "routines, locations, education, work, personal_facts, conversation_context), content (a short "
    "factual sentence starting with 'The user' — never guess or use a gendered pronoun like she/he, "
    "since gender is not known), importance (0.0-1.0), confidence (0.0-1.0, lower if it's an inference "
    "rather than something stated directly). If there is nothing worth remembering, respond with an "
    "empty array: []"
)


class ExtractRequest(BaseModel):
    user_message: str
    companion_reply: str


class MemoryCandidate(BaseModel):
    category: str
    content: str
    importance: float
    confidence: float


class ExtractResponse(BaseModel):
    memories: list[MemoryCandidate]


def _parse_candidates(raw: str) -> list[MemoryCandidate]:
    text = raw.strip()
    text = re.sub(r"^```(json)?", "", text).strip()
    text = re.sub(r"```$", "", text).strip()

    match = re.search(r"\[.*\]", text, re.DOTALL)
    if not match:
        return []

    try:
        items = json.loads(match.group(0))
    except json.JSONDecodeError:
        return []

    candidates: list[MemoryCandidate] = []
    if not isinstance(items, list):
        return []

    for item in items:
        if not isinstance(item, dict):
            continue
        category = item.get("category")
        content = item.get("content")
        if category not in VALID_CATEGORIES or not content:
            continue
        try:
            importance = float(item.get("importance", 0.5))
            confidence = float(item.get("confidence", 0.5))
        except (TypeError, ValueError):
            importance, confidence = 0.5, 0.5
        candidates.append(
            MemoryCandidate(
                category=category,
                content=str(content),
                importance=max(0.0, min(1.0, importance)),
                confidence=max(0.0, min(1.0, confidence)),
            )
        )
    return candidates


@router.post("/extract", response_model=ExtractResponse)
async def extract_memory(req: ExtractRequest) -> ExtractResponse:
    exchange = f"User: {req.user_message}\nCompanion: {req.companion_reply}"
    raw = await chat_completion(
        EXTRACTION_SYSTEM_PROMPT,
        [{"role": "user", "content": exchange}],
        temperature=0.2,
    )
    return ExtractResponse(memories=_parse_candidates(raw))
