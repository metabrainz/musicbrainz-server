/*
 * @flow strict
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

export function formatPercentage(
  $c: CatalystContextT,
  num: number,
  digits: number,
): string {
  return (num || 0).toLocaleString(
    $c.stash.current_language_html,
    {
      maximumFractionDigits: digits,
      minimumFractionDigits: digits,
      style: 'percent',
    },
  );
}

export function formatCount($c: CatalystContextT, num: ?number): string {
  return typeof num === 'number'
    ? num.toLocaleString($c.stash.current_language_html)
    : '';
}

export const TimelineLink = ({
  statName,
}: {statName: string}): React.Element<'a'> => (
  <a
    href={'/statistics/timeline/' + encodeURIComponent(statName)}
    title={l('See on timeline')}
  >
    <img
      alt=""
      className="bottom"
      src={require('../static/images/icons/timeline.png')}
    />
  </a>
);
