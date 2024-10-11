/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import manifest from '../static/manifest.mjs';
import {MAPBOX_ACCESS_TOKEN}
  from '../static/scripts/common/DBDefs-client.mjs';

import PlaceLayout from './PlaceLayout.js';

type MapDataArgsT = {
  +draggable: boolean,
  +place: {
    +coordinates: CoordinatesT | null,
    +name: string,
  },
};

component PlaceMap(mapDataArgs: MapDataArgsT, place: PlaceT) {
  return (
    <PlaceLayout entity={place} page="map" title={l('Map')}>
      {place.coordinates ? (
        MAPBOX_ACCESS_TOKEN ? (
          <>
            <div id="largemap" />
            {manifest('place/map', {'data-args': mapDataArgs})}
          </>
        ) : (
          <p>
            {l(
              `A map cannot be shown because no maps service access token has
               been set for this server.`,
            )}
          </p>
        )
      ) : (
        <p>
          {l('A map cannot be shown because this place has no coordinates.')}
        </p>
      )}
    </PlaceLayout>
  );
}

export default PlaceMap;
