/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import CleanupBanner from '../components/CleanupBanner.js';
import RelationshipsTable from '../components/RelationshipsTable.js';
import * as manifest from '../static/manifest.mjs';
import Annotation from '../static/scripts/common/components/Annotation.js';
import Relationships
  from '../static/scripts/common/components/Relationships.js';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract.js';

import WorkLayout from './WorkLayout.js';

type Props = {
  +eligibleForCleanup: boolean,
  +numberOfRevisions: number,
  +pagedLinkTypeGroup: ?PagedLinkTypeGroupT,
  +pager: ?PagerT,
  +wikipediaExtract: WikipediaExtractT | null,
  +work: WorkT,
};

const WorkIndex = ({
  eligibleForCleanup,
  numberOfRevisions,
  pagedLinkTypeGroup,
  pager,
  wikipediaExtract,
  work,
}: Props): React$Element<typeof WorkLayout> => (
  <WorkLayout entity={work} page="index">
    {eligibleForCleanup ? (
      <CleanupBanner entityType="work" />
    ) : null}
    <Annotation
      annotation={work.latest_annotation}
      collapse
      entity={work}
      numberOfRevisions={numberOfRevisions}
    />
    <WikipediaExtract
      cachedWikipediaExtract={wikipediaExtract}
      entity={work}
    />
    <Relationships source={work} />
    <RelationshipsTable
      entity={work}
      heading={l('Recordings')}
      pagedLinkTypeGroup={pagedLinkTypeGroup}
      pager={pager}
    />
    {manifest.js('work/index', {async: 'async'})}
  </WorkLayout>
);

export default WorkIndex;
