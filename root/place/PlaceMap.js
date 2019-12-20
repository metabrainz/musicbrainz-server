/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import * as manifest from '../static/manifest';

import PlaceLayout from './PlaceLayout';

type Props = {
  +mapDataArgs: {
    +draggable: boolean,
    +place: {
      +coordinates: CoordinatesT | null,
      +name: string,
    },
  },
  +place: PlaceT,
};

const PlaceMap = ({
  mapDataArgs,
  place,
}: Props) => (
  <PlaceLayout entity={place} page="map" title={l('Map')}>
    {place.coordinates ? (
      <>
        <div id="largemap" />
        {manifest.js('place/map.js', {'data-args': mapDataArgs})}
      </>
    ) : (
      <p>
        {l('A map cannot be shown because this place has no coordinates.')}
      </p>
    )}
  </PlaceLayout>
);

export default PlaceMap;
