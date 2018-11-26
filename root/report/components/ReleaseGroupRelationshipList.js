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
import type {ReportReleaseGroupRelationshipT} from '../types';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';

const ReleaseGroupRelationshipList = ({items, pager}: {items: $ReadOnlyArray<ReportReleaseGroupRelationshipT>, pager: PagerT}) => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Relationship Type')}</th>
          <th>{l('Artist')}</th>
          <th>{l('Release Group')}</th>
          <th>{l('Type')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.release_group.gid}>
            <td>
              <a href={'/relationship/' + item.link_gid}>{item.link_name}</a>
            </td>
            <td>
              <ArtistCreditLink artistCredit={item.release_group.artistCredit} />
            </td>
            <td>
              <EntityLink entity={item.release_group} />
            </td>
            <td>{item.release_group.typeName ? item.release_group.typeName : l('Unknown')}</td>
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default ReleaseGroupRelationshipList;
