/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export function formatPluralEntityTypeName(typeName: string): string {
  switch (typeName) {
    case 'area':
      return l('Areas');
    case 'artist':
      return l('Artists');
    case 'collection':
      return l('Collections');
    case 'event':
      return l('Events');
    case 'genre':
      return l('Genres');
    case 'instrument':
      return l('Instruments');
    case 'label':
      return l('Labels');
    case 'mood':
      return l('Moods');
    case 'place':
      return l('Places');
    case 'recording':
      return l('Recordings');
    case 'release':
      return l('Releases');
    case 'release_group':
      return l('Release Groups');
    case 'series':
      return lp('Series', 'plural');
    case 'url':
      return l('URLs');
    case 'work':
      return l('Works');
    default:
      return typeName;
  }
}

export default function formatEntityTypeName(typeName: string): string {
  switch (typeName) {
    case 'area':
      return l('Area');
    case 'artist':
      return l('Artist');
    case 'collection':
      return l('Collection');
    case 'event':
      return l('Event');
    case 'genre':
      return l('Genre');
    case 'instrument':
      return l('Instrument');
    case 'label':
      return l('Label');
    case 'mood':
      return l('Moods');
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
