class RelationshipOption {
  final String id;
  final String label;
  final String description;
  final bool isPremium;

  /// Builds the small preview line shown when this role is selected,
  /// given the label of the currently-chosen personality (if any).
  final String Function(String? personalityLabel) previewBuilder;

  const RelationshipOption({
    required this.id,
    required this.label,
    required this.description,
    required this.previewBuilder,
    this.isPremium = false,
  });
}
