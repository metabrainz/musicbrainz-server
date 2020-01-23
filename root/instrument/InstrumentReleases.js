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
import ReleaseList from '../components/list/ReleaseList';
import PaginatedResults from '../components/PaginatedResults';

import InstrumentLayout from './InstrumentLayout';

type Props = {|
  ...InstrumentCreditsAndRelTypesRoleT,
  +$c: CatalystContextT,
  +instrument: InstrumentT,
  +pager: PagerT,
  +releases: $ReadOnlyArray<ReleaseT>,
|};

const InstrumentReleases = ({
  $c,
  instrument,
  instrumentCreditsAndRelTypes,
  pager,
  releases,
}: Props) => (
  <InstrumentLayout entity={instrument} page="releases" title={l('Releases')}>
    <h2>{l('Releases')}</h2>

    {releases && releases.length > 0 ? (
      <form action="/release/merge_queue" method="post">
        <PaginatedResults pager={pager}>
          <ReleaseList
            checkboxes="add-to-merge"
            instrumentCreditsAndRelTypes={instrumentCreditsAndRelTypes}
            releases={releases}
            showInstrumentCreditsAndRelTypes
          />
        </PaginatedResults>
        {$c.user_exists ? (
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
        {l('No releases found.')}
      </p>
    )}
  </InstrumentLayout>
);

export default withCatalystContext(InstrumentReleases);
