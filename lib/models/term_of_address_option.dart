class TermOfAddressOption {
  final String id;
  final String label;
  final bool isPremium;

  const TermOfAddressOption({
    required this.id,
    required this.label,
    this.isPremium = false,
  });
}
