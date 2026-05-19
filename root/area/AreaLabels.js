/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import LabelList from '../components/list/LabelList.js';
import PaginatedResults from '../components/PaginatedResults.js';
import RelationshipsTable
  from '../components/RelationshipsTable.js';
import {SanitizedCatalystContext} from '../context.mjs';
import manifest from '../static/manifest.mjs';
import ListMergeButtonsRow
  from '../static/scripts/common/components/ListMergeButtonsRow.js';
import {returnToCurrentPage} from '../utility/returnUri.js';

import AreaLayout from './AreaLayout.js';

component AreaLabels(
  area: AreaT,
  labels: ?ReadonlyArray<LabelT>,
  pagedLinkTypeGroup: ?PagedLinkTypeGroupT,
  pager: PagerT,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <AreaLayout entity={area} page="labels" title={l('Labels')}>
      {pagedLinkTypeGroup ? null : (
        <>
          <h2>{l('Labels')}</h2>

          {labels?.length ? (
            <form
              action={'/label/merge_queue?' + returnToCurrentPage($c)}
              method="post"
            >
              <PaginatedResults pager={pager}>
                <LabelList
                  checkboxes="add-to-merge"
                  labels={labels}
                  showRatings
                />
              </PaginatedResults>
              {$c.user ? (
                <>
                  <ListMergeButtonsRow
                    label={l('Add selected labels for merging')}
                  />
                  {manifest(
                    'common/components/ListMergeButtonsRow',
                    {async: true},
                  )}
                </>
              ) : null}
            </form>
          ) : (
            <p>
              {l('This area is not currently associated with any labels.')}
            </p>
          )}
        </>
      )}
      <RelationshipsTable
        entity={area}
        fallbackMessage={l(
          'This area has no relationships to any labels.',
        )}
        heading={l('Relationships')}
        pagedLinkTypeGroup={pagedLinkTypeGroup}
        pager={pager}
      />
      {manifest('common/MB/Control/SelectAll', {async: true})}
      {manifest('common/ratings', {async: true})}
    </AreaLayout>
  );
}

export default AreaLabels;
