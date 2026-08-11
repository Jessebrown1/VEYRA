import '../models/relationship_option.dart';

class RelationshipCatalog {
  RelationshipCatalog._();

  static const List<RelationshipOption> all = [
    RelationshipOption(
      id: 'friend',
      label: 'Friend',
      description: 'Someone easy to talk to, any time.',
      previewBuilder: _friendPreview,
    ),
    RelationshipOption(
      id: 'best_friend',
      label: 'Best Friend',
      description: 'Close, familiar, always in your corner.',
      previewBuilder: _bestFriendPreview,
    ),
    RelationshipOption(
      id: 'study_partner',
      label: 'Study Partner',
      description: 'Focused and encouraging, ready to work.',
      previewBuilder: _studyPreview,
    ),
    RelationshipOption(
      id: 'motivator',
      label: 'Motivator',
      description: 'Energetic and goal-oriented.',
      previewBuilder: _motivatorPreview,
    ),
    RelationshipOption(
      id: 'girlfriend',
      label: 'Girlfriend',
      description: 'Warm, affectionate and romantic.',
      previewBuilder: _romanticPreview,
      isPremium: true,
    ),
    RelationshipOption(
      id: 'boyfriend',
      label: 'Boyfriend',
      description: 'Warm, affectionate and romantic.',
      previewBuilder: _romanticPreview,
      isPremium: true,
    ),
    RelationshipOption(
      id: 'confidant',
      label: 'Confidant',
      description: 'Someone you can tell anything.',
      previewBuilder: _confidantPreview,
      isPremium: true,
    ),
    RelationshipOption(
      id: 'mentor',
      label: 'Mentor',
      description: 'Thoughtful, structured, a little challenging.',
      previewBuilder: _mentorPreview,
      isPremium: true,
    ),
    RelationshipOption(
      id: 'coach',
      label: 'Coach',
      description: 'Direct, driven, keeps you accountable.',
      previewBuilder: _coachPreview,
      isPremium: true,
    ),
    RelationshipOption(
      id: 'gaming_partner',
      label: 'Gaming Partner',
      description: 'Always down for one more round.',
      previewBuilder: _gamingPreview,
      isPremium: true,
    ),
    RelationshipOption(
      id: 'custom',
      label: 'Custom Relationship',
      description: 'Define the relationship entirely on your terms.',
      previewBuilder: _customPreview,
      isPremium: true,
    ),
  ];

  static RelationshipOption byId(String id) =>
      all.firstWhere((r) => r.id == id, orElse: () => all.first);

  static String _friendPreview(String? p) => "Hey! Glad you're here.";
  static String _bestFriendPreview(String? p) => "Hey! I'm glad you're here.";
  static String _studyPreview(String? p) => 'Ready to get some work done together?';
  static String _motivatorPreview(String? p) => "Tell me what we're working toward.";
  static String _romanticPreview(String? p) =>
      "Hey, you. I've been waiting to meet you. ❤️";
  static String _confidantPreview(String? p) => 'Whatever it is, I’m listening.';
  static String _mentorPreview(String? p) => "Let's figure out where you're headed.";
  static String _coachPreview(String? p) => "Let's set a goal and go after it.";
  static String _gamingPreview(String? p) => "Ready when you are. What are we playing?";
  static String _customPreview(String? p) => "Tell me who you'd like me to be.";
}
