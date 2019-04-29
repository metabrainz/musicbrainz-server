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
import type {ReportReleaseAnnotationT} from '../types';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';

const ReleaseAnnotationList = ({
  items,
  pager,
}: {items: $ReadOnlyArray<ReportReleaseAnnotationT>, pager: PagerT}) => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Release')}</th>
          <th>{l('Artist')}</th>
          <th>{l('Annotation')}</th>
          <th style={{width: '10em'}}>{l('Last edited')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.release_id}>
            {item.release ? (
              <>
                <td>
                  <EntityLink entity={item.release} />
                </td>
                <td>
                  <ArtistCreditLink
                    artistCredit={item.release.artistCredit}
                  />
                </td>
              </>
            ) : (
              <td colSpan="2">
                {l('This release no longer exists.')}
              </td>
            )}
            <td dangerouslySetInnerHTML={{__html: item.text}} />
            <td>{item.created}</td>
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default ReleaseAnnotationList;
