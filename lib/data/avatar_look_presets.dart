/// Curated whole-avatar "looks" — each combines existing procedural SVG
/// layers into one complete, ready-made appearance. Users pick a look as a
/// whole here rather than assembling one piece by piece; the individual
/// layer catalog (skin/hair/eyes/outfit/accessory) still exists server-side
/// and can be fine-tuned later from the companion's profile.
class AvatarLookPreset {
  final String name;
  final String skinId;
  final String hairId;
  final String eyeId;
  final String outfitId;
  final String? accessoryId;
  final bool isPremium;

  const AvatarLookPreset({
    required this.name,
    required this.skinId,
    required this.hairId,
    required this.eyeId,
    required this.outfitId,
    this.accessoryId,
    this.isPremium = false,
  });
}

const List<AvatarLookPreset> avatarLookPresets = [
  AvatarLookPreset(
    name: 'Aria',
    skinId: 'skin/skin_01.svg',
    hairId: 'hair/hair_short_black_01.svg',
    eyeId: 'eyes/eyes_round_01.svg',
    outfitId: 'outfits/outfit_casual_01.svg',
  ),
  AvatarLookPreset(
    name: 'Nova',
    skinId: 'skin/skin_02.svg',
    hairId: 'hair/hair_long_brown_05.svg',
    eyeId: 'eyes/eyes_almond_02.svg',
    outfitId: 'outfits/outfit_cozy_04.svg',
  ),
  AvatarLookPreset(
    name: 'Sage',
    skinId: 'skin/skin_03.svg',
    hairId: 'hair/hair_straight_black_13.svg',
    eyeId: 'eyes/eyes_round_01.svg',
    outfitId: 'outfits/outfit_minimal_07.svg',
  ),
  AvatarLookPreset(
    name: 'Wren',
    skinId: 'skin/skin_04.svg',
    hairId: 'hair/hair_wavy_brown_11.svg',
    eyeId: 'eyes/eyes_almond_02.svg',
    outfitId: 'outfits/outfit_casual_01.svg',
  ),
  AvatarLookPreset(
    name: 'Kai',
    skinId: 'skin/skin_05.svg',
    hairId: 'hair/hair_short_brown_02.svg',
    eyeId: 'eyes/eyes_round_01.svg',
    outfitId: 'outfits/outfit_cozy_04.svg',
  ),
  AvatarLookPreset(
    name: 'Iris',
    skinId: 'skin/skin_01.svg',
    hairId: 'hair/hair_long_black_04.svg',
    eyeId: 'eyes/eyes_almond_02.svg',
    outfitId: 'outfits/outfit_minimal_07.svg',
  ),
  AvatarLookPreset(
    name: 'Celeste',
    skinId: 'skin/skin_02.svg',
    hairId: 'hair/hair_long_blonde_06.svg',
    eyeId: 'eyes/eyes_wide_04.svg',
    outfitId: 'outfits/outfit_romantic_05.svg',
    accessoryId: 'accessories/accessory_necklace_03.svg',
    isPremium: true,
  ),
  AvatarLookPreset(
    name: 'Onyx',
    skinId: 'skin/skin_03.svg',
    hairId: 'hair/hair_curly_black_07.svg',
    eyeId: 'eyes/eyes_sleepy_03.svg',
    outfitId: 'outfits/outfit_streetwear_03.svg',
    accessoryId: 'accessories/accessory_glasses_01.svg',
    isPremium: true,
  ),
];
