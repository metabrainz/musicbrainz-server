/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export function formatPluralEntityTypeName(typeName: string): string {
  return match (typeName) {
    'area' => l('Areas'),
    'artist' => l('Artists'),
    'collection' => l('Collections'),
    'event' => l('Events'),
    'genre' => l('Genres'),
    'instrument' => l('Instruments'),
    'label' => l('Labels'),
    'place' => l('Places'),
    'recording' => l('Recordings'),
    'release' => l('Releases'),
    'release_group' => l('Release groups'),
    'series' => lp('Series', 'plural'),
    'url' => l('URLs'),
    'work' => l('Works'),
    _ => typeName,
  };
}

export default function formatEntityTypeName(typeName: string): string {
  return match (typeName) {
    'area' => l('Area'),
    'artist' => l('Artist'),
    'collection' => l('Collection'),
    'event' => l('Event'),
    'genre' => l('Genre'),
    'instrument' => l('Instrument'),
    'label' => l('Label'),
    'place' => l('Place'),
    'recording' => l('Recording'),
    'release' => l('Release'),
    'release_group' => l('Release group'),
    'series' => lp('Series', 'singular'),
    'url' => l('URL'),
    'work' => l('Work'),
    _ => typeName,
  };
}
