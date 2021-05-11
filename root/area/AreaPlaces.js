/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PlaceList from '../components/list/PlaceList';
import PaginatedResults from '../components/PaginatedResults';
import * as manifest from '../static/manifest';
import DBDefs from '../static/scripts/common/DBDefs-client';
import {returnToCurrentPage} from '../utility/returnUri';

import AreaLayout from './AreaLayout';

type Props = {
  +$c: CatalystContextT,
  +area: AreaT,
  +mapDataArgs: {places: $ReadOnlyArray<PlaceT>},
  +pager: PagerT,
  +places: ?$ReadOnlyArray<PlaceT>,
};

const AreaPlaces = ({
  $c,
  area,
  mapDataArgs,
  pager,
  places,
}: Props): React.Element<typeof AreaLayout> => (
  <AreaLayout $c={$c} entity={area} page="places" title={l('Places')}>
    <h2>{l('Places')}</h2>

    {places?.length ? (
      <>
        {DBDefs.MAPBOX_ACCESS_TOKEN ? (
          <>
            <div id="largemap" />
            {manifest.js('area/places-map.js', {'data-args': mapDataArgs})}
          </>
        ) : (
          <p>
            {l(
              `A map cannot be shown because no maps service access token has
               been set for this server.`,
            )}
          </p>
        )}
        <form
          action={'/place/merge_queue?' + returnToCurrentPage($c)}
          method="post"
        >
          <PaginatedResults pager={pager}>
            <PlaceList
              $c={$c}
              checkboxes="add-to-merge"
              places={places}
              showRatings
            />
          </PaginatedResults>
          {$c.user ? (
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

export default AreaPlaces;
