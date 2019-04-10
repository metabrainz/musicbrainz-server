/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import loopParity from '../../utility/loopParity';
import type {ReportArtistRelationshipT} from '../types';

const ArtistRelationshipList = ({
  items,
  pager,
}: {items: $ReadOnlyArray<ReportArtistRelationshipT>, pager: PagerT}) => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Relationship Type')}</th>
          <th>{l('Artist')}</th>
          <th>{l('Type')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.artist.gid}>
            <td>
              <a href={'/relationship/' + encodeURIComponent(item.link_gid)}>
                {l_relationships(item.link_name)}
              </a>
            </td>
            <td>
              <EntityLink entity={item.artist} />
            </td>
            <td>
              {item.artist.typeName
                ? lp_attributes(item.artist.typeName, 'artist_type')
                : l('Unknown')}
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default ArtistRelationshipList;
