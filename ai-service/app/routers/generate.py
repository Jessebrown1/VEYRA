from typing import Optional

from fastapi import APIRouter
from pydantic import BaseModel

from ..llm_client import chat_completion
from ..prompts import build_system_prompt

router = APIRouter(prefix="/generate", tags=["generate"])


class RecentMessage(BaseModel):
    sender: str  # "user" | "companion"
    content: str


class ReplyRequest(BaseModel):
    companion_name: str
    personality_traits: dict[str, float]
    relationship_id: str
    user_preferred_name: str
    user_term: Optional[str] = None
    local_hour: int
    memories: list[str] = []
    area_hint: Optional[str] = None
    recent_messages: list[RecentMessage] = []
    user_message: str


class ReplyResponse(BaseModel):
    reply: str


@router.post("/reply", response_model=ReplyResponse)
async def generate_reply(req: ReplyRequest) -> ReplyResponse:
    system_prompt = build_system_prompt(
        companion_name=req.companion_name,
        personality_traits=req.personality_traits,
        relationship_id=req.relationship_id,
        user_preferred_name=req.user_preferred_name,
        user_term=req.user_term,
        local_hour=req.local_hour,
        memories=req.memories,
        area_hint=req.area_hint,
    )
    messages = [{"role": "user" if m.sender == "user" else "assistant", "content": m.content} for m in req.recent_messages]
    messages.append({"role": "user", "content": req.user_message})
    reply = await chat_completion(system_prompt, messages)
    return ReplyResponse(reply=reply)


class WelcomeRequest(BaseModel):
    companion_name: str
    personality_traits: dict[str, float]
    relationship_id: str
    user_preferred_name: str
    user_term: Optional[str] = None
    local_hour: int


class WelcomeResponse(BaseModel):
    message: str


@router.post("/welcome", response_model=WelcomeResponse)
async def generate_welcome(req: WelcomeRequest) -> WelcomeResponse:
    system_prompt = build_system_prompt(
        companion_name=req.companion_name,
        personality_traits=req.personality_traits,
        relationship_id=req.relationship_id,
        user_preferred_name=req.user_preferred_name,
        user_term=req.user_term,
        local_hour=req.local_hour,
        memories=[],
        extra_instruction=(
            "This is the very first message you have ever sent this user. Introduce yourself by name "
            "in one or two short sentences, in character, as if you're just now meeting them. Do not "
            "use quotation marks around the message."
        ),
    )
    reply = await chat_completion(
        system_prompt,
        [{"role": "user", "content": "(the app has just introduced you to the user for the first time)"}],
        temperature=0.9,
    )
    return WelcomeResponse(message=reply)


class NotificationRequest(BaseModel):
    companion_name: str
    personality_traits: dict[str, float]
    relationship_id: str
    user_preferred_name: str
    reason: str  # "inactivity" | "sleep"
    context_hint: Optional[str] = None


class NotificationResponse(BaseModel):
    message: str


@router.post("/notification", response_model=NotificationResponse)
async def generate_notification(req: NotificationRequest) -> NotificationResponse:
    if req.reason == "sleep":
        instruction = (
            "Write a very short (under 20 words), gentle push notification suggesting the user get some "
            "rest, in character. Do not make medical claims or diagnose fatigue. No quotation marks."
        )
    else:
        instruction = (
            "Write a very short (under 20 words) push notification checking in on the user after a "
            "period of inactivity, in character. Warm, not needy or guilt-inducing. No quotation marks."
        )
    if req.context_hint:
        instruction += f" You may reference this if it fits naturally: {req.context_hint}"

    system_prompt = build_system_prompt(
        companion_name=req.companion_name,
        personality_traits=req.personality_traits,
        relationship_id=req.relationship_id,
        user_preferred_name=req.user_preferred_name,
        user_term=None,
        local_hour=12,
        memories=[],
        extra_instruction=instruction,
    )
    reply = await chat_completion(
        system_prompt,
        [{"role": "user", "content": "(generate the notification now)"}],
        temperature=0.85,
    )
    return NotificationResponse(message=reply.strip('"'))
