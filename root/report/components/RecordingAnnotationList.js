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
import type {ReportRecordingAnnotationT} from '../types';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';

const RecordingAnnotationList = ({
  items,
  pager,
}: {items: $ReadOnlyArray<ReportRecordingAnnotationT>, pager: PagerT}) => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Artist')}</th>
          <th>{l('Recording')}</th>
          <th>{l('Annotation')}</th>
          <th style={{width: '10em'}}>{l('Last edited')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.recording.gid}>
            <td>
              <ArtistCreditLink artistCredit={item.recording.artistCredit} />
            </td>
            <td>
              <EntityLink entity={item.recording} />
            </td>
            <td dangerouslySetInnerHTML={{__html: item.text}} />
            <td>{item.created}</td>
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default RecordingAnnotationList;
