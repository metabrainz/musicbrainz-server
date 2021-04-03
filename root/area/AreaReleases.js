/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from '../components/list/ReleaseList';
import PaginatedResults from '../components/PaginatedResults';
import RelationshipsTable from '../components/RelationshipsTable';
import {returnToCurrentPage} from '../utility/returnUri';

import AreaLayout from './AreaLayout';

type Props = {
  +$c: CatalystContextT,
  +area: AreaT,
  +pagedLinkTypeGroup: ?PagedLinkTypeGroupT,
  +pager: PagerT,
  +releases: ?$ReadOnlyArray<ReleaseT>,
};

const AreaReleases = ({
  $c,
  area,
  pagedLinkTypeGroup,
  pager,
  releases,
}: Props): React.Element<typeof AreaLayout> => (
  <AreaLayout entity={area} page="releases" title={l('Releases')}>
    {pagedLinkTypeGroup ? null : (
      <>
        <h2>{l('Releases')}</h2>

        {releases?.length ? (
          <form
            action={'/release/merge_queue?' + returnToCurrentPage($c)}
            method="post"
          >
            <PaginatedResults pager={pager}>
              <ReleaseList checkboxes="add-to-merge" releases={releases} />
            </PaginatedResults>
            {$c.user ? (
              <div className="row">
                <span className="buttons">
                  <button type="submit">
                    {l('Add selected releases for merging')}
                  </button>
                </span>
              </div>
            ) : null}
          </form>
        ) : (
          <p>
            {l('This area is not currently associated with any releases.')}
          </p>
        )}
      </>
    )}

    <RelationshipsTable
      $c={$c}
      entity={area}
      fallbackMessage={l(
        'This area has no relationships to any releases.',
      )}
      heading={l('Relationships')}
      pagedLinkTypeGroup={pagedLinkTypeGroup}
      pager={pager}
    />
  </AreaLayout>
);

export default AreaReleases;
