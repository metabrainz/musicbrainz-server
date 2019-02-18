/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../context';
import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';
import {l} from '../static/scripts/common/i18n';
import PaginatedResults from '../components/PaginatedResults';
import EntityLink from '../static/scripts/common/components/EntityLink';

import FilterLink from './FilterLink';
import type {ReportCollaborationT, ReportDataT} from './types';

const CollaborationRelationships = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportCollaborationT>) => {
  let lastID = 0;
  let currentID = 0;

  return (
    <Layout fullWidth title={l('Artists with collaboration relationships')}>
      <h1>{l('Artists with collaboration relationships')}</h1>

      <ul>
        <li>
          {l(`This report lists artists which have collaboration relationships
              but no URL relationships. If the collaboration has its own
              independent name, do nothing. If it is in a format like
              "X with Y" or "X & Y", you should probably split it.
              See {how_to_split_artists|How to Split Artists}.`,
          {how_to_split_artists: '/doc/How_to_Split_Artists'})}
        </li>
        <li>{l('Total artists found: {count}', {count: pager.total_entries})}</li>
        <li>{l('Generated on {date}', {date: formatUserDate($c.user, generated)})}</li>

        {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
      </ul>

      <PaginatedResults pager={pager}>
        <table className="tbl">
          <thead>
            <tr>
              <th width="150px">{l('Collaboration')}</th>
              <th>{l('Collaborator')}</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item, index) => {
              lastID = currentID;
              currentID = item.id1;

              return (
                <>
                  {lastID === item.id1 ? null : (
                    <tr className="even" key={item.artist1.gid}>
                      <td colSpan="2">
                        <EntityLink entity={item.artist1} />
                      </td>
                    </tr>
                  )}
                  <tr key={item.artist0.gid}>
                    <td />
                    <td>
                      <EntityLink entity={item.artist0} />
                    </td>
                  </tr>
                </>
              );
            })}
          </tbody>
        </table>
      </PaginatedResults>
    </Layout>
  );
};

export default withCatalystContext(CollaborationRelationships);
