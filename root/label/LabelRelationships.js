/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RelationshipsTable from '../components/RelationshipsTable.js';
import Relationships
  from '../static/scripts/common/components/Relationships.js';

import LabelLayout from './LabelLayout.js';

type Props = {
  +$c: CatalystContextT,
  +label: LabelT,
  +pagedLinkTypeGroup: ?PagedLinkTypeGroupT,
  +pager: ?PagerT,
};

const LabelRelationships = ({
  $c,
  label,
  pagedLinkTypeGroup,
  pager,
}: Props): React.Element<typeof LabelLayout> => (
  <LabelLayout
    entity={label}
    page="relationships"
    title={l('Relationships')}
  >
    {pagedLinkTypeGroup ? null : (
      <Relationships showIfEmpty source={label} />
    )}
    <RelationshipsTable
      $c={$c}
      entity={label}
      heading={l('Appearances')}
      pagedLinkTypeGroup={pagedLinkTypeGroup}
      pager={pager}
    />
  </LabelLayout>
);

export default LabelRelationships;
