/** Server-side mirror of the personality/relationship/term catalogs the Flutter
 * app ships (lib/data/*.dart). Kept here so the backend can validate and
 * enforce entitlements independently of what the client sends. */

export interface CatalogEntry {
  id: string;
  isPremium: boolean;
}

export const PERSONALITY_CATALOG: CatalogEntry[] = [
  { id: 'caring', isPremium: false },
  { id: 'calm', isPremium: false },
  { id: 'supportive', isPremium: false },
  { id: 'curious', isPremium: false },
  { id: 'confident', isPremium: true },
  { id: 'romantic', isPremium: true },
  { id: 'intelligent', isPremium: true },
  { id: 'playful', isPremium: true },
  { id: 'custom', isPremium: true },
];

export const RELATIONSHIP_CATALOG: CatalogEntry[] = [
  { id: 'friend', isPremium: false },
  { id: 'best_friend', isPremium: false },
  { id: 'study_partner', isPremium: false },
  { id: 'motivator', isPremium: false },
  { id: 'girlfriend', isPremium: true },
  { id: 'boyfriend', isPremium: true },
  { id: 'confidant', isPremium: true },
  { id: 'mentor', isPremium: true },
  { id: 'coach', isPremium: true },
  { id: 'gaming_partner', isPremium: true },
  { id: 'custom', isPremium: true },
];

const TERM_OF_ADDRESS_CATALOG: Record<string, CatalogEntry[]> = {
  friend: [
    { id: 'first_name', isPremium: false },
    { id: 'buddy', isPremium: false },
    { id: 'bestie', isPremium: true },
  ],
  best_friend: [
    { id: 'first_name', isPremium: false },
    { id: 'bestie', isPremium: false },
    { id: 'bro', isPremium: false },
  ],
  study_partner: [
    { id: 'first_name', isPremium: false },
    { id: 'buddy', isPremium: false },
  ],
  motivator: [
    { id: 'first_name', isPremium: false },
    { id: 'buddy', isPremium: false },
  ],
  girlfriend: [
    { id: 'first_name', isPremium: false },
    { id: 'babe', isPremium: false },
    { id: 'hun', isPremium: true },
    { id: 'love', isPremium: true },
  ],
  boyfriend: [
    { id: 'first_name', isPremium: false },
    { id: 'babe', isPremium: false },
    { id: 'hun', isPremium: true },
    { id: 'love', isPremium: true },
  ],
};

const DEFAULT_TERMS: CatalogEntry[] = [
  { id: 'first_name', isPremium: false },
  { id: 'buddy', isPremium: false },
];

export function termsForRelationship(relationshipId: string): CatalogEntry[] {
  const base = TERM_OF_ADDRESS_CATALOG[relationshipId] ?? DEFAULT_TERMS;
  return [...base, { id: 'custom', isPremium: true }];
}

export function personalityExists(id: string): boolean {
  return PERSONALITY_CATALOG.some((p) => p.id === id);
}

export function relationshipExists(id: string): boolean {
  return RELATIONSHIP_CATALOG.some((r) => r.id === id);
}

export function isPersonalityPremium(id: string): boolean {
  return PERSONALITY_CATALOG.find((p) => p.id === id)?.isPremium ?? true;
}

export function isRelationshipPremium(id: string): boolean {
  return RELATIONSHIP_CATALOG.find((r) => r.id === id)?.isPremium ?? true;
}

export function isTermPremium(relationshipId: string, termId: string): boolean {
  return termsForRelationship(relationshipId).find((t) => t.id === termId)?.isPremium ?? true;
}
