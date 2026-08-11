import { AvatarAssetCategory, PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const AVATAR_BASE = 'assets/avatar';
const WALLPAPER_BASE = 'assets/wallpapers';

interface AvatarAssetSeed {
  category: AvatarAssetCategory;
  name: string;
  file: string;
  isPremium: boolean;
}

const SKIN: AvatarAssetSeed[] = [1, 2, 3, 4, 5].map((n) => ({
  category: 'skin',
  name: `Skin ${n}`,
  file: `skin/skin_0${n}.svg`,
  isPremium: false,
}));

const HAIR_FILES: { style: string; color: string; file: string }[] = [
  { style: 'short', color: 'black', file: 'hair_short_black_01.svg' },
  { style: 'short', color: 'brown', file: 'hair_short_brown_02.svg' },
  { style: 'short', color: 'blonde', file: 'hair_short_blonde_03.svg' },
  { style: 'long', color: 'black', file: 'hair_long_black_04.svg' },
  { style: 'long', color: 'brown', file: 'hair_long_brown_05.svg' },
  { style: 'long', color: 'blonde', file: 'hair_long_blonde_06.svg' },
  { style: 'curly', color: 'black', file: 'hair_curly_black_07.svg' },
  { style: 'curly', color: 'brown', file: 'hair_curly_brown_08.svg' },
  { style: 'curly', color: 'blonde', file: 'hair_curly_blonde_09.svg' },
  { style: 'wavy', color: 'black', file: 'hair_wavy_black_10.svg' },
  { style: 'wavy', color: 'brown', file: 'hair_wavy_brown_11.svg' },
  { style: 'wavy', color: 'blonde', file: 'hair_wavy_blonde_12.svg' },
  { style: 'straight', color: 'black', file: 'hair_straight_black_13.svg' },
  { style: 'straight', color: 'brown', file: 'hair_straight_brown_14.svg' },
  { style: 'straight', color: 'blonde', file: 'hair_straight_blonde_15.svg' },
  { style: 'braided', color: 'black', file: 'hair_braided_black_16.svg' },
  { style: 'braided', color: 'brown', file: 'hair_braided_brown_17.svg' },
  { style: 'braided', color: 'blonde', file: 'hair_braided_blonde_18.svg' },
];

const PREMIUM_HAIR_STYLES = new Set(['curly', 'braided']);

const HAIR: AvatarAssetSeed[] = HAIR_FILES.map((h) => ({
  category: 'hair',
  name: `${h.style[0].toUpperCase()}${h.style.slice(1)} ${h.color[0].toUpperCase()}${h.color.slice(1)}`,
  file: `hair/${h.file}`,
  isPremium: PREMIUM_HAIR_STYLES.has(h.style) || h.color === 'blonde',
}));

const EYES: AvatarAssetSeed[] = [
  { category: 'eyes', name: 'Round', file: 'eyes/eyes_round_01.svg', isPremium: false },
  { category: 'eyes', name: 'Almond', file: 'eyes/eyes_almond_02.svg', isPremium: false },
  { category: 'eyes', name: 'Sleepy', file: 'eyes/eyes_sleepy_03.svg', isPremium: true },
  { category: 'eyes', name: 'Wide', file: 'eyes/eyes_wide_04.svg', isPremium: true },
];

const OUTFITS: AvatarAssetSeed[] = [
  { category: 'outfit', name: 'Casual', file: 'outfits/outfit_casual_01.svg', isPremium: false },
  { category: 'outfit', name: 'Cozy', file: 'outfits/outfit_cozy_04.svg', isPremium: false },
  { category: 'outfit', name: 'Minimal', file: 'outfits/outfit_minimal_07.svg', isPremium: false },
  { category: 'outfit', name: 'Formal', file: 'outfits/outfit_formal_02.svg', isPremium: true },
  { category: 'outfit', name: 'Streetwear', file: 'outfits/outfit_streetwear_03.svg', isPremium: true },
  { category: 'outfit', name: 'Romantic', file: 'outfits/outfit_romantic_05.svg', isPremium: true },
  { category: 'outfit', name: 'Sport', file: 'outfits/outfit_sport_06.svg', isPremium: true },
];

const ACCESSORIES: AvatarAssetSeed[] = [
  { category: 'accessory', name: 'Glasses', file: 'accessories/accessory_glasses_01.svg', isPremium: true },
  { category: 'accessory', name: 'Earrings', file: 'accessories/accessory_earrings_02.svg', isPremium: true },
  { category: 'accessory', name: 'Necklace', file: 'accessories/accessory_necklace_03.svg', isPremium: true },
  { category: 'accessory', name: 'Hat', file: 'accessories/accessory_hat_04.svg', isPremium: true },
];

interface WallpaperSeed {
  category: string;
  name: string;
  file: string;
  isPremium: boolean;
}

const WALLPAPERS: WallpaperSeed[] = [
  { category: 'night', name: 'Moonlit Bedroom', file: 'night/wallpaper_night_01_moonlit_bedroom.svg', isPremium: false },
  { category: 'night', name: 'City at Night', file: 'night/wallpaper_night_02_city_at_night.svg', isPremium: true },
  { category: 'night', name: 'Starry Sky', file: 'night/wallpaper_night_03_starry_sky.svg', isPremium: true },
  { category: 'cozy', name: 'Warm Bedroom', file: 'cozy/wallpaper_cozy_01_warm_bedroom.svg', isPremium: false },
  { category: 'cozy', name: 'Soft Lamp', file: 'cozy/wallpaper_cozy_02_soft_lamp.svg', isPremium: true },
  { category: 'cozy', name: 'Rainy Window', file: 'cozy/wallpaper_cozy_03_rainy_window.svg', isPremium: true },
  { category: 'romantic', name: 'Candlelit', file: 'romantic/wallpaper_romantic_01_candlelit.svg', isPremium: false },
  {
    category: 'romantic',
    name: 'Sunset Apartment',
    file: 'romantic/wallpaper_romantic_02_sunset_apartment.svg',
    isPremium: true,
  },
  {
    category: 'romantic',
    name: 'Soft Pink Night',
    file: 'romantic/wallpaper_romantic_03_soft_pink_night.svg',
    isPremium: true,
  },
  { category: 'minimal', name: 'Dark Studio', file: 'minimal/wallpaper_minimal_01_dark_studio.svg', isPremium: false },
  {
    category: 'minimal',
    name: 'Modern Apartment',
    file: 'minimal/wallpaper_minimal_02_modern_apartment.svg',
    isPremium: true,
  },
  { category: 'minimal', name: 'Gray Interior', file: 'minimal/wallpaper_minimal_03_gray_interior.svg', isPremium: true },
  { category: 'nature', name: 'Forest at Night', file: 'nature/wallpaper_nature_01_forest_night.svg', isPremium: false },
  { category: 'nature', name: 'Beach Sunset', file: 'nature/wallpaper_nature_02_beach_sunset.svg', isPremium: true },
  {
    category: 'nature',
    name: 'Mountain Evening',
    file: 'nature/wallpaper_nature_03_mountain_evening.svg',
    isPremium: true,
  },
  { category: 'city', name: 'Neon Street', file: 'city/wallpaper_city_01_neon_street.svg', isPremium: false },
  { category: 'city', name: 'Rooftop', file: 'city/wallpaper_city_02_rooftop.svg', isPremium: true },
  { category: 'city', name: 'Skyline View', file: 'city/wallpaper_city_03_skyline_view.svg', isPremium: true },
];

async function main() {
  const allAvatarAssets = [...SKIN, ...HAIR, ...EYES, ...OUTFITS, ...ACCESSORIES];

  for (const asset of allAvatarAssets) {
    await prisma.avatarAsset.upsert({
      where: { id: asset.file },
      update: { name: asset.name, isPremium: asset.isPremium, assetPath: `${AVATAR_BASE}/${asset.file}` },
      create: {
        id: asset.file,
        category: asset.category,
        name: asset.name,
        assetPath: `${AVATAR_BASE}/${asset.file}`,
        isPremium: asset.isPremium,
      },
    });
  }

  for (const wallpaper of WALLPAPERS) {
    await prisma.wallpaperAsset.upsert({
      where: { id: wallpaper.file },
      update: {
        name: wallpaper.name,
        category: wallpaper.category,
        isPremium: wallpaper.isPremium,
        assetPath: `${WALLPAPER_BASE}/${wallpaper.file}`,
      },
      create: {
        id: wallpaper.file,
        name: wallpaper.name,
        category: wallpaper.category,
        assetPath: `${WALLPAPER_BASE}/${wallpaper.file}`,
        isPremium: wallpaper.isPremium,
      },
    });
  }

  console.log(`Seeded ${allAvatarAssets.length} avatar assets and ${WALLPAPERS.length} wallpapers.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
