/*
 * @flow
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

export function formatPercentage(num: number, digits: number, $c: CatalystContextT) {
  return (num || 0).toLocaleString($c.stash.current_language,
    {maximumFractionDigits: digits, minimumFractionDigits: digits, style: 'percent'});
}

export function formatCount(num: ?number, $c: CatalystContextT) {
  return typeof num === 'number' ? num.toLocaleString($c.stash.current_language) : '';
}
