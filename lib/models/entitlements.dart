class Entitlements {
  final bool isPlus;
  final int memoryLimit;
  final Map<String, bool> features;

  const Entitlements({required this.isPlus, required this.memoryLimit, required this.features});

  factory Entitlements.fromJson(Map<String, dynamic> json) => Entitlements(
        isPlus: json['isPlus'] as bool,
        memoryLimit: json['memoryLimit'] as int,
        features: Map<String, bool>.from(json['features'] as Map),
      );

  static const free = Entitlements(isPlus: false, memoryLimit: 50, features: {});
}
