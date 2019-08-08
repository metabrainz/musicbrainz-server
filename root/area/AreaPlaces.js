/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../context';
import PlaceList from '../components/list/PlaceList';
import PaginatedResults from '../components/PaginatedResults';
import * as manifest from '../static/manifest';

import AreaLayout from './AreaLayout';

type Props = {|
  +$c: CatalystContextT,
  +area: AreaT,
  +mapDataArgs: {places: $ReadOnlyArray<PlaceT>},
  +pager: PagerT,
  +places: $ReadOnlyArray<PlaceT>,
|};

const AreaPlaces = ({
  $c,
  area,
  mapDataArgs,
  pager,
  places,
}: Props) => (
  <AreaLayout entity={area} page="places" title={l('Places')}>
    <h2>{l('Places')}</h2>

    {places && places.length > 0 ? (
      <>
        <div id="largemap" />
        {manifest.js('area/places-map.js', {'data-args': mapDataArgs})}
        <form action="/place/merge_queue" method="post">
          <PaginatedResults pager={pager}>
            <PlaceList
              checkboxes="add-to-merge"
              places={places}
            />
          </PaginatedResults>
          {$c.user_exists ? (
            <div className="row">
              <span className="buttons">
                <button type="submit">
                  {l('Add selected labels for merging')}
                </button>
              </span>
            </div>
          ) : null}
        </form>
      </>
    ) : (
      <p>
        {l('This area is not currently associated with any places.')}
      </p>
    )}
  </AreaLayout>
);

export default withCatalystContext(AreaPlaces);
