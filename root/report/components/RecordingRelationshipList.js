/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import loopParity from '../../utility/loopParity';
import type {ReportRecordingRelationshipT} from '../types';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';

type Props = {
  +items: $ReadOnlyArray<ReportRecordingRelationshipT>,
  +pager: PagerT,
  +showArtist?: boolean,
  +showDates?: boolean,
};

const RecordingRelationshipList = ({
  items,
  pager,
  showDates = false,
  showArtist = false,
}: Props): React.Element<typeof PaginatedResults> => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          {showDates ? (
            <>
              <th>{l('Begin date')}</th>
              <th>{l('End date')}</th>
            </>
          ) : null}
          <th>{l('Relationship Type')}</th>
          {showArtist ? (
            <th>{l('Artist')}</th>
          ) : null}
          <th>{l('Recording')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.recording_id}>
            {showDates ? (
              <>
                <td>
                  {item.begin}
                </td>
                <td>
                  {item.end}
                </td>
              </>
            ) : null}
            <td>
              <a href={'/relationship/' + encodeURIComponent(item.link_gid)}>
                {l_relationships(item.link_name)}
              </a>
            </td>
            {item.recording ? (
              <>
                {showArtist ? (
                  <td>
                    <ArtistCreditLink
                      artistCredit={item.recording.artistCredit}
                    />
                  </td>
                ) : null}
                <td>
                  <EntityLink entity={item.recording} />
                </td>
              </>
            ) : (
              <td colSpan="2">
                {l('This recording no longer exists.')}
              </td>
            )}
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default RecordingRelationshipList;
