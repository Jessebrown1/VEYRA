import '../models/personality_option.dart';

/// Spec explicitly excludes "Funny" from the v1 personality set (kept for a
/// future update) and limits the free tier to a subset of options.
class PersonalityCatalog {
  PersonalityCatalog._();

  static const List<PersonalityOption> all = [
    PersonalityOption(
      id: 'caring',
      label: 'Caring',
      description: 'Warm, thoughtful and attentive.',
    ),
    PersonalityOption(
      id: 'calm',
      label: 'Calm',
      description: 'Patient, relaxed and reassuring.',
    ),
    PersonalityOption(
      id: 'supportive',
      label: 'Supportive',
      description: 'Encouraging, understanding and dependable.',
    ),
    PersonalityOption(
      id: 'curious',
      label: 'Curious',
      description: 'Interested in your world and eager to learn.',
    ),
    PersonalityOption(
      id: 'confident',
      label: 'Confident',
      description: 'Self-assured, direct and composed.',
      isPremium: true,
    ),
    PersonalityOption(
      id: 'romantic',
      label: 'Romantic',
      description: 'Affectionate, warm and emotionally expressive.',
      isPremium: true,
    ),
    PersonalityOption(
      id: 'intelligent',
      label: 'Intelligent',
      description: 'Thoughtful, analytical and curious.',
      isPremium: true,
    ),
    PersonalityOption(
      id: 'playful',
      label: 'Playful',
      description: 'Lighthearted, energetic and teasing.',
      isPremium: true,
    ),
    PersonalityOption(
      id: 'custom',
      label: 'Custom',
      description: 'Combine traits to build a personality of your own.',
      isPremium: true,
    ),
  ];

  static PersonalityOption byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => all.first);
}
