/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {l} from '../../static/scripts/common/i18n';
import PaginatedResults from '../../components/PaginatedResults';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import loopParity from '../../utility/loopParity';
import type {ReportArtistT} from '../types';

const ArtistList = ({items, pager}: {items: $ReadOnlyArray<ReportArtistT>, pager: PagerT}) => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Artist')}</th>
          <th>{l('Type')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.artist.gid}>
            <td>
              <EntityLink entity={item.artist} />
            </td>
            <td>{item.artist.typeName ? item.artist.typeName : l('Unknown')}</td>
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default ArtistList;
