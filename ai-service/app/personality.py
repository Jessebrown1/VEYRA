"""Translates a weighted personality-trait dict into a concrete prompt fragment.
This is the actual personality engine — traits shape tone, verbosity, and initiative,
not just a label appended to the prompt."""

TRAIT_DESCRIPTIONS = {
    "caring": "warm, attentive, and emotionally supportive",
    "calm": "patient, relaxed, and reassuring, using unhurried language",
    "confident": "self-assured, direct, and composed",
    "curious": "inquisitive, and asks genuine follow-up questions about the user's world",
    "supportive": "encouraging and dependable, and validates the user's feelings",
    "romantic": "affectionate and emotionally expressive, with gentle warmth and occasional terms of endearment",
    "intelligent": "thoughtful and analytical, offering considered perspectives",
    "playful": "lighthearted and energetic, teasing gently, with more casual phrasing",
    "custom": "shaped by whatever the user has asked of you",
}


def build_personality_fragment(traits: dict[str, float]) -> str:
    if not traits:
        return "Speak naturally and warmly, with no particular exaggerated trait."

    ranked = sorted(traits.items(), key=lambda kv: kv[1], reverse=True)
    dominant = [t for t, w in ranked if w >= 0.5][:3] or [ranked[0][0]]
    descriptors = [TRAIT_DESCRIPTIONS.get(t, t) for t in dominant]

    avg_weight = sum(traits.values()) / len(traits)
    if avg_weight < 0.55:
        length_hint = "Keep replies fairly short (1-3 sentences) unless the user clearly wants more detail."
    elif avg_weight < 0.8:
        length_hint = "Reply at a natural conversational length — a few sentences is usually enough."
    else:
        length_hint = "You can be more expressive and a little more detailed when it genuinely fits."

    initiative_hint = (
        "Take initiative sometimes — ask a question or bring something up rather than only reacting."
        if traits.get("curious", 0) >= 0.5 or traits.get("confident", 0) >= 0.5
        else "Follow the user's lead more than you lead the conversation."
    )

    return (
        f"Your personality is {', '.join(descriptors)}. "
        f"Let this shape your tone, word choice, and how much initiative you take. "
        f"{length_hint} {initiative_hint}"
    )
