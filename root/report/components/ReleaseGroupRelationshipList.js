/*
 * @flow
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
import type {ReportReleaseGroupRelationshipT} from '../types';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';

type Props = {
  +items: $ReadOnlyArray<ReportReleaseGroupRelationshipT>,
  +pager: PagerT,
};

const ReleaseGroupRelationshipList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Relationship Type')}</th>
          <th>{l('Artist')}</th>
          <th>{l('Release Group')}</th>
          <th>{l('Type')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.release_group_id}>
            <td>
              <a href={'/relationship/' + encodeURIComponent(item.link_gid)}>
                {l_relationships(item.link_name)}
              </a>
            </td>
            {item.release_group ? (
              <>
                <td>
                  <ArtistCreditLink
                    artistCredit={item.release_group.artistCredit}
                  />
                </td>
                <td>
                  <EntityLink entity={item.release_group} />
                </td>
                <td>
                  {item.release_group.l_type_name
                    ? item.release_group.l_type_name
                    : l('Unknown')}
                </td>
              </>
            ) : (
              <td colSpan="3">
                {l('This release group no longer exists.')}
              </td>
            )}
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default ReleaseGroupRelationshipList;
