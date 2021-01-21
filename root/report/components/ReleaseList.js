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
import ReleaseLanguageScript from '../../components/ReleaseLanguageScript';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import loopParity from '../../utility/loopParity';
import type {ReportReleaseT} from '../types';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';

type Props = {
  +items: $ReadOnlyArray<ReportReleaseT>,
  +pager: PagerT,
  +showLanguageAndScript?: boolean,
  +subPath?: string,
};

const ReleaseList = ({
  items,
  pager,
  showLanguageAndScript = false,
  subPath,
}: Props): React.Element<typeof PaginatedResults> => {
  const colSpan = showLanguageAndScript ? 3 : 2;

  return (
    <PaginatedResults pager={pager}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('Release')}</th>
            <th>{l('Artist')}</th>
            {showLanguageAndScript ? <th>{l('Language/Script')}</th> : null}
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => {
            const release = item.release;
            return (
              <tr className={loopParity(index)} key={item.release_id}>
                {release ? (
                  <>
                    <td>
                      <EntityLink entity={release} subPath={subPath} />
                    </td>
                    <td>
                      <ArtistCreditLink
                        artistCredit={release.artistCredit}
                      />
                    </td>
                    {showLanguageAndScript ? (
                      <td>
                        <ReleaseLanguageScript release={release} />
                      </td>
                    ) : null}
                  </>
                ) : (
                  <td colSpan={colSpan}>
                    {l('This release no longer exists.')}
                  </td>
                )}
              </tr>
            );
          })}
        </tbody>
      </table>
    </PaginatedResults>
  );
};

export default ReleaseList;
