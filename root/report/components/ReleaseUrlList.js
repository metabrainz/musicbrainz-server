/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults.js';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink.js';
import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import bracketed from '../../static/scripts/common/utility/bracketed.js';
import type {ReportReleaseUrlT} from '../types.js';

type Props = {
  +items: $ReadOnlyArray<ReportReleaseUrlT>,
  +pager: PagerT,
};

const ReleaseUrlList = ({
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
            <th>{l('Release')}</th>
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
                {item.release ? (
                  <tr key={item.release.gid}>
                    <td />
                    <td>
                      <EntityLink entity={item.release} />
                    </td>
                    <td>
                      <ArtistCreditLink
                        artistCredit={item.release.artistCredit}
                      />
                    </td>
                  </tr>
                ) : (
                  <tr key={`removed-${item.release_id}`}>
                    <td />
                    <td colSpan="2">
                      {l('This release no longer exists.')}
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

export default ReleaseUrlList;
