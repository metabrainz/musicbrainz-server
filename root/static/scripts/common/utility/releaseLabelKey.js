/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';

import clean from './clean.js';

export default function releaseLabelKey(releaseLabel: ReleaseLabelT): string {
  let result = '';
  const label = ko.unwrap(releaseLabel.label);
  if (label) {
    result += (
      label.id || (nonEmpty(label.name) ? 'name-' + label.name : '')
    );
  }
  result += '\0';
  result += clean(ko.unwrap(releaseLabel.catalogNumber));
  return result;
}
