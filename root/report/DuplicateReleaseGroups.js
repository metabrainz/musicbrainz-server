/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
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

component DuplicateReleaseGroups(...{
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
      description={exp.l_reports(
        `This report lists release groups with very similar names and
        artists. If the releases in the release groups should be grouped
        together (see the {url|guidelines}), they can be merged. If they
        shouldn't be grouped together but they can be distinguished by
        the release group types, such as when an artist has an album and
        single with the same name, then there is usually no need to
        change anything. In other cases, a disambiguation comment may be
        helpful.`,
        {url: '/doc/Style/Release_Group'},
      )}
      entityType="release_group"
      filtered={filtered}
      generated={generated}
      title={l_reports('Possible duplicate release groups')}
      totalEntries={pager.total_entries}
    >
      <PaginatedResults pager={pager}>
        <table className="tbl">
          <thead>
            <tr>
              <th>{l('Artist')}</th>
              <th>{l('Release group')}</th>
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
                            : lp('Unknown', 'type')}
                        </td>
                      </>
                    ) : (
                      <>
                        <td />
                        <td colSpan="2">
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

export default DuplicateReleaseGroups;
