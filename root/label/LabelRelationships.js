/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Relationships from '../components/Relationships';
import RelationshipsTable from '../components/RelationshipsTable';
import EntityLink from '../static/scripts/common/components/EntityLink';

import LabelLayout from './LabelLayout';

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
    $c={$c}
    entity={label}
    page="relationships"
    title={l('Relationships')}
  >
    {pagedLinkTypeGroup ? null : (
      label.relationships?.length ? (
        <Relationships source={label} />
      ) : (
        <>
          <h2 className="relationships">{l('Relationships')}</h2>
          <p>
            {exp.l(
              '{link} has no relationships.',
              {link: <EntityLink entity={label} />},
            )}
          </p>
        </>
      )
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
