/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults';
import loopParity from '../utility/loopParity';
import EntityLink from '../static/scripts/common/components/EntityLink';

import ReportLayout from './components/ReportLayout';
import type {ReportArtistT, ReportDataT} from './types';

const ArtistsWithMultipleOccurrencesInArtistCredits = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report lists artists that appear more than once
       in different positions within the same artist credit.`,
    )}
    entityType="artist"
    filtered={filtered}
    generated={generated}
    title={l('Artists occurring multiple times in the same artist credit')}
    totalEntries={pager.total_entries}
  >
    <PaginatedResults pager={pager}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('Artist')}</th>
            <th>{l('Type')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => (
            <tr className={loopParity(index)} key={item.artist_id}>
              {item.artist ? (
                <>
                  <td>
                    <EntityLink entity={item.artist} subPath="aliases" />
                  </td>
                  <td>
                    {nonEmpty(item.artist.typeName)
                      ? lp_attributes(item.artist.typeName, 'artist_type')
                      : l('Unknown')}
                  </td>
                </>
              ) : (
                <td colSpan="2">
                  {l('This artist no longer exists.')}
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </PaginatedResults>
  </ReportLayout>
);

export default ArtistsWithMultipleOccurrencesInArtistCredits;
