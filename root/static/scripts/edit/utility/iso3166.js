/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export const ISO_3166_VARIANTS: Array<Iso3166Variant> =
  ['ISO 3166-1', 'ISO 3166-2', 'ISO 3166-3'];

export type Iso3166Variant =
  | 'ISO 3166-1'
  | 'ISO 3166-2'
  | 'ISO 3166-3';

export type Iso3166VariantSnake =
  | 'iso_3166_1'
  | 'iso_3166_2'
  | 'iso_3166_3';

/*
 * Get the ISO 3166 variant as a snake_case string
 */
export function iso3166VariantSnake(
  variant: Iso3166Variant,
): Iso3166VariantSnake {
  return match (variant) {
    'ISO 3166-1' => 'iso_3166_1',
    'ISO 3166-2' => 'iso_3166_2',
    'ISO 3166-3' => 'iso_3166_3',
  };
}

const iso31661Pattern = /^[A-Z]{2}$/;
const iso31662Pattern = /^[A-Z]{2}-[A-Z0-9]+$/;
const iso31663Pattern = /^[A-Z]{4}$/;

/*
 * Validates whether `value` is a valid ISO 3166 code of the given `variant`
 */
export function isValidIso3166(
  variant: Iso3166Variant,
  value: string,
): boolean {
  return match (variant) {
    'ISO 3166-1' => iso31661Pattern.test(value),
    'ISO 3166-2' => iso31662Pattern.test(value),
    'ISO 3166-3' => iso31663Pattern.test(value),
  };
}
