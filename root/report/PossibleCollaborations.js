/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistList from './components/ArtistList';
import ReportLayout from './components/ReportLayout';
import type {ReportArtistT, ReportDataT} from './types';

const PossibleCollaborations = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={exp.l(
      `This report lists artists which have “&” in their names
       but no membership-related relationships (none of member,
       collaborator, conductor, founder nor subgroup). If the artist
       is usually seen as an actual group, member relationships should
       be added. If it’s a short term collaboration, it should be split
       if possible (see {how_to_split_artists|How to Split Artists}).
       If it is a collaboration with its own name and can’t be split,
       collaboration relationships should be added to it. For some
       special cases, such as “Person & His Orchestra”, conductor
       and/or founder might be the best choice.`,
      {how_to_split_artists: '/doc/How_to_Split_Artists'},
    )}
    entityType="artist"
    filtered={filtered}
    generated={generated}
    title={l('Artists that may be collaborations')}
    totalEntries={pager.total_entries}
  >
    <ArtistList items={items} pager={pager} />
  </ReportLayout>
);


export default PossibleCollaborations;
