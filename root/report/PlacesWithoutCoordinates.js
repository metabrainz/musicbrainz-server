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
import loopParity from '../utility/loopParity';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink';
import EntityLink from '../static/scripts/common/components/EntityLink';

import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportPlaceRelationshipT} from './types';

const PlacesWithoutCoordinates = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportPlaceRelationshipT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l('This report lists places without coordinates.')}
    entityType="place"
    filtered={filtered}
    generated={generated}
    title={l('Places without coordinates')}
    totalEntries={pager.total_entries}
  >
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
  </ReportLayout>
);

export default PlacesWithoutCoordinates;
