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
import EntityLink from '../../static/scripts/common/components/EntityLink';
import expand2react from '../../static/scripts/common/i18n/expand2react';
import loopParity from '../../utility/loopParity';
import type {ReportArtistAnnotationT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportArtistAnnotationT>,
  +pager: PagerT,
};

const ArtistAnnotationList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Artist')}</th>
          <th>{l('Type')}</th>
          <th>{l('Annotation')}</th>
          <th style={{width: '10em'}}>{l('Last edited')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.artist_id}>
            {item.artist ? (
              <>
                <td>
                  <EntityLink entity={item.artist} />
                </td>
                <td>
                  {nonEmpty(item.artist.typeName)
                    ? lp_attributes(item.artist.typeName, 'artist_type')
                    : l('Unknown')}
                </td>
              </>
            ) : (
              <td colSpan="2">
                {l('This artist no longer exists.')}
              </td>
            )}
            <td>{expand2react(item.text)}</td>
            <td>{item.created}</td>
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default ArtistAnnotationList;
