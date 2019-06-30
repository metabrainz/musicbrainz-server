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
import LabelList from '../components/list/LabelList';
import PaginatedResults from '../components/PaginatedResults';

import AreaLayout from './AreaLayout';

type Props = {|
  +$c: CatalystContextT,
  +area: AreaT,
  +labels: $ReadOnlyArray<LabelT>,
  +pager: PagerT,
|};

const AreaLabels = ({
  $c,
  area,
  labels,
  pager,
}: Props) => (
  <AreaLayout entity={area} page="labels" title={l('Labels')}>
    <h2>{l('Labels')}</h2>

    {labels.length > 0 ? (
      <form action="/label/merge_queue" method="post">
        <PaginatedResults pager={pager}>
          <LabelList
            checkboxes="add-to-merge"
            labels={labels}
            showRatings
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
    ) : (
      <p>
        {l('This area is not currently associated with any labels.')}
      </p>
    )}
  </AreaLayout>
);

export default withCatalystContext(AreaLabels);
