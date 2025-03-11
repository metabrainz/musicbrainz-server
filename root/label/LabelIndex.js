/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CleanupBanner from '../components/CleanupBanner.js';
import ReleaseList from '../components/list/ReleaseList.js';
import PaginatedResults from '../components/PaginatedResults.js';
import RelatedEntitiesDisplay from '../components/RelatedEntitiesDisplay.js';
import {SanitizedCatalystContext} from '../context.mjs';
import manifest from '../static/manifest.mjs';
import Annotation from '../static/scripts/common/components/Annotation.js';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink.js';
import Filter from '../static/scripts/common/components/Filter.js';
import {type ReleaseFilterT}
  from '../static/scripts/common/components/FilterForm.js';
import ListMergeButtonsRow
  from '../static/scripts/common/components/ListMergeButtonsRow.js';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract.js';
import commaOnlyList from '../static/scripts/common/i18n/commaOnlyList.js';

import LabelLayout from './LabelLayout.js';

component LabelIndex(
  ajaxFilterFormUrl: string,
  eligibleForCleanup: boolean,
  filterForm: ?ReleaseFilterT,
  hasFilter: boolean,
  label: LabelT,
  numberOfRevisions: number,
  pager: PagerT,
  releases: ?$ReadOnlyArray<ReleaseT>,
  renamedFrom: $ReadOnlyArray<LabelT>,
  renamedInto: $ReadOnlyArray<LabelT>,
  wikipediaExtract: WikipediaExtractT | null,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  return (
    <LabelLayout entity={label} page="index">
      {eligibleForCleanup ? (
        <CleanupBanner entityType="label" />
      ) : null}
      <Annotation
        annotation={label.latest_annotation}
        collapse
        entity={label}
        numberOfRevisions={numberOfRevisions}
      />
      {renamedFrom.length ? (
        <RelatedEntitiesDisplay title={l('Previously known as')}>
          {commaOnlyList(renamedFrom.map(
            label => <DescriptiveLink entity={label} key={label.gid} />,
          ))}
        </RelatedEntitiesDisplay>
      ) : null}
      {renamedInto.length ? (
        <RelatedEntitiesDisplay title={l('Renamed to')}>
          {commaOnlyList(renamedInto.map(
            label => <DescriptiveLink entity={label} key={label.gid} />,
          ))}
        </RelatedEntitiesDisplay>
      ) : null}
      <WikipediaExtract
        cachedWikipediaExtract={wikipediaExtract}
        entity={label}
      />
      <h2 className="releases">{l('Releases')}</h2>

      <Filter
        ajaxFormUrl={ajaxFilterFormUrl}
        initialFilterForm={filterForm}
      />

      {releases?.length ? (
        <form
          action="/release/merge_queue"
          method="post"
        >
          <PaginatedResults pager={pager}>
            <ReleaseList
              checkboxes="add-to-merge"
              filterLabel={label}
              releases={releases}
            />
          </PaginatedResults>
          {$c.user ? (
            <>
              <ListMergeButtonsRow
                label={l('Add selected releases for merging')}
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
            ? l('No releases found that match this search.')
            : l('This label does not have any releases.')}
        </p>
      )}
      {manifest('label/index', {async: 'async'})}
    </LabelLayout>
  );
}

export default LabelIndex;
