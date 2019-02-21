/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {l} from '../../static/scripts/common/i18n';
import PaginatedResults from '../../components/PaginatedResults';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import type {ReportReleaseGroupURLT} from '../types';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';

const ReleaseGroupUrlList = ({
  items,
  pager,
}: {items: $ReadOnlyArray<ReportReleaseGroupURLT>, pager: PagerT}) => {
  let lastGID = 0;
  let currentGID = 0;

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
                      <EntityLink
                        content={item.url.href_url}
                        entity={item.url}
                      />
                    </td>
                  </tr>
                )}
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
              </>
            );
          })}
        </tbody>
      </table>
    </PaginatedResults>
  );
};

export default ReleaseGroupUrlList;
