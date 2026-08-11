import '../models/term_of_address_option.dart';

class TermOfAddressCatalog {
  TermOfAddressCatalog._();

  static const TermOfAddressOption yourName =
      TermOfAddressOption(id: 'first_name', label: 'Your name');

  static const TermOfAddressOption createYourOwn =
      TermOfAddressOption(id: 'custom', label: 'Create your own', isPremium: true);

  static const Map<String, List<TermOfAddressOption>> _byRelationship = {
    'friend': [
      yourName,
      TermOfAddressOption(id: 'buddy', label: 'Buddy'),
      TermOfAddressOption(id: 'bestie', label: 'Bestie', isPremium: true),
    ],
    'best_friend': [
      yourName,
      TermOfAddressOption(id: 'bestie', label: 'Bestie'),
      TermOfAddressOption(id: 'bro', label: 'Bro'),
    ],
    'study_partner': [
      yourName,
      TermOfAddressOption(id: 'buddy', label: 'Buddy'),
    ],
    'motivator': [
      yourName,
      TermOfAddressOption(id: 'buddy', label: 'Buddy'),
    ],
    'girlfriend': [
      yourName,
      TermOfAddressOption(id: 'babe', label: 'Babe'),
      TermOfAddressOption(id: 'hun', label: 'Hun', isPremium: true),
      TermOfAddressOption(id: 'love', label: 'Love', isPremium: true),
    ],
    'boyfriend': [
      yourName,
      TermOfAddressOption(id: 'babe', label: 'Babe'),
      TermOfAddressOption(id: 'hun', label: 'Hun', isPremium: true),
      TermOfAddressOption(id: 'love', label: 'Love', isPremium: true),
    ],
  };

  static const List<TermOfAddressOption> _fallback = [
    yourName,
    TermOfAddressOption(id: 'buddy', label: 'Buddy'),
  ];

  static List<TermOfAddressOption> forRelationship(String relationshipId) {
    final options = List<TermOfAddressOption>.from(
      _byRelationship[relationshipId] ?? _fallback,
    );
    options.add(createYourOwn);
    return options;
  }
}
