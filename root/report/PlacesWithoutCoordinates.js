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
import loopParity from '../utility/loopParity';
import EntityLink from '../static/scripts/common/components/EntityLink';

import FilterLink from './FilterLink';
import type {ReportDataT, ReportPlaceRelationshipT} from './types';

const PlacesWithoutCoordinates = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportPlaceRelationshipT>) => (
  <Layout fullWidth title={l('Places without coordinates')}>
    <h1>{l('Places without coordinates')}</h1>

    <ul>
      <li>{l('This report lists places without coordinates.')}
      </li>
      <li>{l('Total places found: {count}', {__react: true, count: pager.total_entries})}</li>
      <li>{l('Generated on {date}', {__react: true, date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <PaginatedResults pager={pager}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('Place')}</th>
            <th>{l('Address')}</th>
            <th>{l('Area')}</th>
            <th>{l('Search for coordinates')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item, index) => {
            const query = encodeURIComponent(item.place.name + ' ' + item.place.address + (item.place.area ? ' ' + item.place.area.name : ''));
            return (
              <tr className={loopParity(index)} key={item.place.gid}>
                <td>
                  <EntityLink entity={item.place} />
                </td>
                <td>{item.place.address}</td>
                <td>
                  {item.place.area ? <EntityLink entity={item.place.area} /> : null}
                </td>
                <td className="search-links">
                  <span className="no-favicon">
                    <a
                      href={"https://www.openstreetmap.org/search?query=" + query}
                      target="_blank"
                      title="OpenStreetMap"
                    >
                      {'OSM'}
                    </a>
                  </span>
                  {' | '}
                  <span>
                    <a
                      href={"https://www.qwant.com/local/?q=" + query}
                      target="_blank"
                      title="Qwant Local"
                    >
                      {'QL'}
                    </a>
                  </span>
                  {' | '}
                  <span>
                    <a
                      href={"https://www.mapquest.com/search/results/?query=" + query}
                      target="_blank"
                      title="MapQuest"
                    >
                      {'MQ'}
                    </a>
                  </span>
                  {' | '}
                  <span>
                    <a
                      href={"https://www.google.com/maps/search/" + query}
                      target="_blank"
                      title="Google Maps"
                    >
                      {'GM'}
                    </a>
                  </span>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </PaginatedResults>
  </Layout>
);

export default withCatalystContext(PlacesWithoutCoordinates);
