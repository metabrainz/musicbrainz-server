/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';

import ReportLayout from './components/ReportLayout.js';
import type {ReportCollaborationT, ReportDataT} from './types.js';

component CollaborationRelationships(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportCollaborationT>) {
  let lastID = 0;
  let currentID = 0;

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={exp.l_reports(
        `This report lists artists which have collaboration relationships
         but no URL relationships. If the collaboration has its own
         independent name, do nothing. If it is in a format like
         "X with Y" or "X & Y", you should probably split it.
         See {how_to_split_artists|How to Split Artists}.`,
        {how_to_split_artists: '/doc/How_to_Split_Artists'},
      )}
      entityType="artist"
      filtered={filtered}
      generated={generated}
      title={l_reports('Artists with collaboration relationships')}
      totalEntries={pager.total_entries}
    >
      <PaginatedResults pager={pager}>
        <table className="tbl">
          <thead>
            <tr>
              <th width="150px">{l_reports('Collaboration')}</th>
              <th>{l_reports('Collaborator')}</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item) => {
              lastID = currentID;
              currentID = item.id1;

              return (
                <React.Fragment
                  key={item.id1 + '-' + item.id0}
                >
                  {lastID === item.id1 ? null : (
                    <tr className="even">
                      <td colSpan={2}>
                        {item.artist1 ? (
                          <EntityLink entity={item.artist1} />
                        ) : (
                          l_reports('This artist no longer exists.')
                        )}
                      </td>
                    </tr>
                  )}
                  <tr>
                    <td />
                    <td>
                      {item.artist0 ? (
                        <EntityLink entity={item.artist0} />
                      ) : (
                        l_reports('This artist no longer exists.')
                      )}
                    </td>
                  </tr>
                </React.Fragment>
              );
            })}
          </tbody>
        </table>
      </PaginatedResults>
    </ReportLayout>
  );
}

export default CollaborationRelationships;
