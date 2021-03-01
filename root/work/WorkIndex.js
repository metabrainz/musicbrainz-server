/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Annotation from '../static/scripts/common/components/Annotation';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract';
import CleanupBanner from '../components/CleanupBanner';
import Relationships from '../components/Relationships';
import RelationshipsTable from '../components/RelationshipsTable';
import * as manifest from '../static/manifest';

import WorkLayout from './WorkLayout';

type Props = {
  +$c: CatalystContextT,
  +eligibleForCleanup: boolean,
  +numberOfRevisions: number,
  +pagedLinkTypeGroup: ?PagedLinkTypeGroupT,
  +pager: ?PagerT,
  +wikipediaExtract: WikipediaExtractT | null,
  +work: WorkT,
};

const WorkIndex = ({
  $c,
  eligibleForCleanup,
  numberOfRevisions,
  pagedLinkTypeGroup,
  pager,
  wikipediaExtract,
  work,
}: Props): React.Element<typeof WorkLayout> => (
  <WorkLayout $c={$c} entity={work} page="index">
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
      $c={$c}
      entity={work}
      heading={l('Recordings')}
      pagedLinkTypeGroup={pagedLinkTypeGroup}
      pager={pager}
    />
    {manifest.js('work/index.js', {async: 'async'})}
  </WorkLayout>
);

export default WorkIndex;
