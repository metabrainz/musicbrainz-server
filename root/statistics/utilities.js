/*
 * @flow
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export function formatPercentage(
  $c: CatalystContextT,
  num: number,
  digits: number,
) {
  return (num || 0).toLocaleString($c.stash.current_language_html,
    {maximumFractionDigits: digits, minimumFractionDigits: digits, style: 'percent'});
}

export function formatCount($c: CatalystContextT, num: ?number) {
  return typeof num === 'number' ? num.toLocaleString($c.stash.current_language_html) : '';
}
