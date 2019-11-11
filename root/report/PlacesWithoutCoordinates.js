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
import PaginatedResults from '../components/PaginatedResults';
import loopParity from '../utility/loopParity';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink';
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
      <li>
        {l('This report lists places without coordinates.')}
      </li>
      <li>
        {texp.l('Total places found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

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
            const place = item.place;
            const query = place ? (
              encodeURIComponent(
                place.name +
                ' ' +
                place.address +
                (place.area ? ' ' + place.area.name : ''),
              )
            ) : '';
            return (
              <tr className={loopParity(index)} key={item.place_id}>
                {place ? (
                  <>
                    <td>
                      <EntityLink entity={place} />
                    </td>
                    <td>{place.address}</td>
                    <td>
                      {place.area
                        ? <DescriptiveLink entity={place.area} />
                        : null}
                    </td>
                    <td className="search-links">
                      <span className="no-favicon">
                        <a
                          href={
                            'https://www.openstreetmap.org/search?query=' + query
                          }
                          rel="noopener noreferrer"
                          target="_blank"
                          title="OpenStreetMap"
                        >
                          {'OSM'}
                        </a>
                      </span>
                      {' | '}
                      <span>
                        <a
                          href={'https://www.qwant.com/local/?q=' + query}
                          rel="noopener noreferrer"
                          target="_blank"
                          title="Qwant Local"
                        >
                          {'QL'}
                        </a>
                      </span>
                      {' | '}
                      <span>
                        <a
                          href={
                            'https://www.mapquest.com/search/results/?query=' +
                            query
                          }
                          rel="noopener noreferrer"
                          target="_blank"
                          title="MapQuest"
                        >
                          {'MQ'}
                        </a>
                      </span>
                      {' | '}
                      <span>
                        <a
                          href={'https://www.google.com/maps/search/' + query}
                          rel="noopener noreferrer"
                          target="_blank"
                          title="Google Maps"
                        >
                          {'GM'}
                        </a>
                      </span>
                    </td>
                  </>
                ) : (
                  <td colSpan="4">
                    {l('This place no longer exists.')}
                  </td>
                )}
              </tr>
            );
          })}
        </tbody>
      </table>
    </PaginatedResults>
  </Layout>
);

export default withCatalystContext(PlacesWithoutCoordinates);
