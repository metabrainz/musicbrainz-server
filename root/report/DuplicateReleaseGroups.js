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
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';
import EntityLink from '../static/scripts/common/components/EntityLink';
import loopParity from '../utility/loopParity';

import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportReleaseGroupT} from './types';

type ReportReleaseGroupWithKeyT = {
  ...ReportReleaseGroupT,
  +key: string,
};

const DuplicateReleaseGroups = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupWithKeyT>):
React.Element<typeof ReportLayout> => {
  let currentKey = '';
  let lastKey = '';

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={exp.l(
        `This report lists release groups with very similar names and
        artists. If the releases in the release groups should be grouped
        together (see the {url|guidelines}), they can be merged. If they
        shouldn\'t be grouped together but they can be distinguished by
        the release group types, e.g. when an artist has an album and
        single with the same name, then there is usually no need to
        change anything. In other cases, a disambiguation comment may be
        helpful.`,
        {url: '/doc/Style/Release_Group'},
      )}
      entityType="release_group"
      filtered={filtered}
      generated={generated}
      title={l('Possible duplicate release groups')}
      totalEntries={pager.total_entries}
    >
      <PaginatedResults pager={pager}>
        <table className="tbl">
          <thead>
            <tr>
              <th>{l('Artist')}</th>
              <th>{l('Release Group')}</th>
              <th>{l('Type')}</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item, index) => {
              lastKey = currentKey;
              currentKey = item.key;

              return (
                <>
                  {lastKey === item.key ? null : (
                    <tr className="subh">
                      <td colSpan="4" />
                    </tr>
                  )}
                  <tr
                    className={loopParity(index)}
                    key={item.release_group_id}
                  >
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
                          {nonEmpty(item.release_group.l_type_name)
                            ? item.release_group.l_type_name
                            : l('Unknown')}
                        </td>
                      </>
                    ) : (
                      <>
                        <td />
                        <td colSpan="2">
                          {l('This release group no longer exists.')}
                        </td>
                      </>
                    )}
                  </tr>
                </>
              );
            })}
          </tbody>
        </table>
      </PaginatedResults>
    </ReportLayout>
  );
};

export default DuplicateReleaseGroups;
