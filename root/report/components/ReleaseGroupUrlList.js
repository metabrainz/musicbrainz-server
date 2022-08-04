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
import bracketed from '../../static/scripts/common/utility/bracketed';
import type {ReportReleaseGroupUrlT} from '../types';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';

type Props = {
  +items: $ReadOnlyArray<ReportReleaseGroupUrlT>,
  +pager: PagerT,
};

const ReleaseGroupUrlList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  let lastGID: string = '';
  let currentGID: string = '';

  return (
    <PaginatedResults pager={pager}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('URL')}</th>
            <th>{l('Release Group')}</th>
            <th>{l('Artist')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item) => {
            lastGID = currentGID;
            currentGID = item.url.gid;

            return (
              <>
                {lastGID === item.url.gid ? null : (
                  <tr className="even" key={item.url.gid}>
                    <td colSpan="3">
                      <a href={item.url.name}>
                        {item.url.name}
                      </a>
                      {' '}
                      {bracketed(
                        <a href={'/url/' + item.url.gid}>
                          {item.url.gid}
                        </a>,
                      )}
                    </td>
                  </tr>
                )}
                {item.release_group ? (
                  <tr key={item.release_group.gid}>
                    <td />
                    <td>
                      <EntityLink entity={item.release_group} />
                    </td>
                    <td>
                      <ArtistCreditLink
                        artistCredit={item.release_group.artistCredit}
                      />
                    </td>
                  </tr>
                ) : (
                  <tr key={`removed-${item.release_group_id}`}>
                    <td />
                    <td colSpan="2">
                      {l('This release group no longer exists.')}
                    </td>
                  </tr>
                )}
              </>
            );
          })}
        </tbody>
      </table>
    </PaginatedResults>
  );
};

export default ReleaseGroupUrlList;
