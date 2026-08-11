/** Central feature map — never scatter `if (user.isPremium)` checks around the
 * codebase. Anything not listed here is free by default. */
export type Feature =
  | 'advanced_memory'
  | 'advanced_relationships'
  | 'advanced_personalities'
  | 'advanced_avatar'
  | 'premium_wallpapers'
  | 'custom_themes'
  | 'advanced_notifications'
  | 'expanded_vision'
  | 'custom_personality'
  | 'advanced_context';

export const PLUS_ONLY_FEATURES: Feature[] = [
  'advanced_memory',
  'advanced_relationships',
  'advanced_personalities',
  'advanced_avatar',
  'premium_wallpapers',
  'custom_themes',
  'advanced_notifications',
  'expanded_vision',
  'custom_personality',
  'advanced_context',
];

export const FREE_MEMORY_LIMIT = 50;
export const PLUS_MEMORY_LIMIT = 1000;

export const FREE_PERSONALITY_IDS = ['caring', 'calm', 'supportive', 'curious'];
export const FREE_RELATIONSHIP_IDS = ['friend', 'best_friend', 'study_partner', 'motivator'];
