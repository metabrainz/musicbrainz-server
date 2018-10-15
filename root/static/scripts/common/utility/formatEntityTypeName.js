/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {l, lp} from '../i18n';

export default function formatEntityTypeName(typeName: string) {
  switch (typeName) {
    case 'area':
      return l('Area');
    case 'artist':
      return l('Artist');
    case 'collection':
      return l('Collection');
    case 'event':
      return l('Event');
    case 'instrument':
      return l('Instrument');
    case 'label':
      return l('Label');
    case 'place':
      return l('Place');
    case 'recording':
      return l('Recording');
    case 'release':
      return l('Release');
    case 'release_group':
      return l('Release Group');
    case 'series':
      return lp('Series', 'singular');
    case 'url':
      return l('URL');
    case 'work':
      return l('Work');
    default:
      return typeName;
  }
}
