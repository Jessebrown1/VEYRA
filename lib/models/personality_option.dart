class PersonalityOption {
  final String id;
  final String label;
  final String description;
  final bool isPremium;

  const PersonalityOption({
    required this.id,
    required this.label,
    required this.description,
    this.isPremium = false,
  });
}
