/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PlaceList from '../components/list/PlaceList.js';
import PaginatedResults from '../components/PaginatedResults.js';
import {SanitizedCatalystContext} from '../context.mjs';
import manifest from '../static/manifest.mjs';
import ListMergeButtonsRow
  from '../static/scripts/common/components/ListMergeButtonsRow.js';
import {MAPBOX_ACCESS_TOKEN}
  from '../static/scripts/common/DBDefs-client.mjs';
import {returnToCurrentPage} from '../utility/returnUri.js';

import AreaLayout from './AreaLayout.js';

component AreaPlaces(
  area: AreaT,
  mapDataArgs: {places: $ReadOnlyArray<PlaceT>},
  pager: PagerT,
  places: ?$ReadOnlyArray<PlaceT>,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <AreaLayout entity={area} page="places" title={l('Places')}>
      <h2>{l('Places')}</h2>

      {places?.length ? (
        <>
          {MAPBOX_ACCESS_TOKEN ? (
            <>
              <div id="largemap" />
              {manifest('area/places-map', {'data-args': mapDataArgs})}
            </>
          ) : (
            <p>
              {l(
                `A map cannot be shown because no maps service access token
                 has been set for this server.`,
              )}
            </p>
          )}
          <form
            action={'/place/merge_queue?' + returnToCurrentPage($c)}
            method="post"
          >
            <PaginatedResults pager={pager}>
              <PlaceList
                checkboxes="add-to-merge"
                places={places}
                showRatings
              />
            </PaginatedResults>
            {$c.user ? (
              <>
                <ListMergeButtonsRow
                  label={l('Add selected places for merging')}
                />
                {manifest(
                  'common/components/ListMergeButtonsRow',
                  {async: 'async'},
                )}
              </>
            ) : null}
          </form>
        </>
      ) : (
        <p>
          {l('This area is not currently associated with any places.')}
        </p>
      )}
      {manifest('common/MB/Control/SelectAll', {async: 'async'})}
      {manifest('common/ratings', {async: 'async'})}
    </AreaLayout>
  );
}

export default AreaPlaces;
