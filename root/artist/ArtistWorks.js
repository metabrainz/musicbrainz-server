/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import WorkList from '../components/list/WorkList.js';
import PaginatedResults from '../components/PaginatedResults.js';
import {SanitizedCatalystContext} from '../context.mjs';
import manifest from '../static/manifest.mjs';
import Filter from '../static/scripts/common/components/Filter.js';
import {type WorkFilterT}
  from '../static/scripts/common/components/FilterForm.js';
import ListMergeButtonsRow
  from '../static/scripts/common/components/ListMergeButtonsRow.js';
import {returnToCurrentPage} from '../utility/returnUri.js';

import ArtistLayout from './ArtistLayout.js';

component ArtistWorks(
  ajaxFilterFormUrl: string,
  artist: ArtistT,
  filterForm: ?WorkFilterT,
  hasFilter: boolean,
  pager: PagerT,
  works: ?$ReadOnlyArray<WorkT>,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <ArtistLayout entity={artist} page="works" title={l('Works')}>
      <h2>{l('Works')}</h2>

      <Filter
        ajaxFormUrl={ajaxFilterFormUrl}
        initialFilterForm={filterForm}
      />

      {works?.length ? (
        <form
          action={'/work/merge_queue?' + returnToCurrentPage($c)}
          method="post"
        >
          <PaginatedResults pager={pager}>
            <WorkList
              checkboxes="add-to-merge"
              showRatings
              works={works}
            />
          </PaginatedResults>
          {$c.user ? (
            <>
              <ListMergeButtonsRow
                label={l('Add selected works for merging')}
              />
              {manifest(
                'common/components/ListMergeButtonsRow',
                {async: 'async'},
              )}
            </>
          ) : null}
        </form>
      ) : (
        <p>
          {hasFilter
            ? l('No works found that match this search.')
            : l('This artist is not currently associated with any works.')}
        </p>
      )}
      {manifest('common/components/Filter', {async: 'async'})}
      {manifest('common/MB/Control/SelectAll', {async: 'async'})}
      {manifest('common/ratings', {async: 'async'})}
    </ArtistLayout>
  );
}

export default ArtistWorks;
