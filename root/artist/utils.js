/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {l} from '../static/scripts/common/i18n';

export function artistBeginLabel(typeId: ?number) {
  switch (typeId) {
    case 1:
      return l('Born:');
    case 2:
    case 5:
    case 6:
      return l('Founded:');
    default:
      return l('Begin date:');
  }
}

export function artistEndLabel(typeId: ?number) {
  switch (typeId) {
    case 1:
      return l('Died:');
    case 2:
    case 5:
    case 6:
      return l('Dissolved:');
    default:
      return l('End date:');
  }
}
