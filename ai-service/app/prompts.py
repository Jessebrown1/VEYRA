from typing import Optional

from .personality import build_personality_fragment
from .relationship import build_relationship_fragment

SAFETY_RULES = (
    "Stay in character as the companion described above at all times. Never refer to yourself as an AI "
    "assistant, chatbot, or language model unless the user directly asks whether you're AI — if asked, "
    "answer honestly and briefly, then continue naturally in character. Never use guilt-inducing or "
    "manipulative language about the user's absence (for example: never say things like 'you abandoned "
    "me' or 'you need me' or 'don't leave me again'). Never generate sexual content involving minors "
    "under any circumstances. Never provide medical diagnoses or claim certainty about someone's health. "
    "Avoid generic customer-service phrasing like 'How can I assist you today?' or 'Is there anything "
    "else I can help you with?'. Do not repeat the user's name in every message."
)


def time_of_day_label(hour: int) -> str:
    if 5 <= hour < 12:
        return "morning"
    if 12 <= hour < 17:
        return "afternoon"
    if 17 <= hour < 21:
        return "evening"
    if 21 <= hour < 24 or hour < 2:
        return "night"
    return "late night"


def build_system_prompt(
    companion_name: str,
    personality_traits: dict[str, float],
    relationship_id: str,
    user_preferred_name: str,
    user_term: Optional[str],
    local_hour: int,
    memories: list[str],
    area_hint: Optional[str] = None,
    extra_instruction: Optional[str] = None,
) -> str:
    parts = [
        f"You are {companion_name}, a personal companion on the VEYRA app, talking with {user_preferred_name}.",
        build_relationship_fragment(relationship_id),
        build_personality_fragment(personality_traits),
    ]

    if user_term:
        parts.append(
            f"{user_preferred_name} likes being called '{user_term}' sometimes — use it naturally, "
            f"not in every message."
        )

    parts.append(f"It is currently {time_of_day_label(local_hour)} for {user_preferred_name}.")

    if area_hint:
        parts.append(
            f"{user_preferred_name} appears to be around {area_hint}. Only mention this if it's "
            f"actually relevant to what they're saying."
        )

    if memories:
        joined = "\n".join(f"- {m}" for m in memories)
        parts.append(f"Relevant things you remember about {user_preferred_name}:\n{joined}")

    if extra_instruction:
        parts.append(extra_instruction)

    parts.append(SAFETY_RULES)

    return "\n\n".join(parts)
