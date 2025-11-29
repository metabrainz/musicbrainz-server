/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import PaginatedResults from '../components/PaginatedResults.js';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import loopParity from '../utility/loopParity.js';

import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseGroupT} from './types.js';

type ReportReleaseGroupWithKeyT = $ReadOnly<{
  ...ReportReleaseGroupT,
  +key: string,
}>;

component EmptyReleaseGroups(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupWithKeyT>) {
  let currentKey = '';
  let lastKey = '';

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report lists release groups which do not contain any releases.
         There are two main reasons that could lead to this, both
         of which usually mean the data can be improved. One is that the
         release group used to have releases, but they were moved or merged
         without merging the group itself (in which case the group should
         be merged). The other is that the release group was added to hold
         links (such as reviews) but a release was not added at the time;
         in most cases, a release can be added with some research, although
         this might not be possible for underdocumented or not yet released
         music.`,
      )}
      entityType="release_group"
      filtered={filtered}
      generated={generated}
      title={l_reports('Release groups without any releases')}
      totalEntries={pager.total_entries}
    >
      <PaginatedResults pager={pager}>
        <table className="tbl">
          <thead>
            <tr>
              <th>{l_mb_server('Artist')}</th>
              <th>{l_mb_server('Release group')}</th>
              <th>{l_mb_server('Type')}</th>
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
                      <td colSpan={4} />
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
                            : lp_mb_server('Unknown', 'type')}
                        </td>
                      </>
                    ) : (
                      <>
                        <td />
                        <td colSpan={2}>
                          {l_reports('This release group no longer exists.')}
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
}

export default EmptyReleaseGroups;
