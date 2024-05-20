/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function addQuotes(
  variable: Expand2ReactInput,
): Expand2ReactOutput {
  return exp.l('“{variable}”', {variable});
}

export function addQuotesText(variable: string): string {
  return texp.l('“{variable}”', {variable});
}
