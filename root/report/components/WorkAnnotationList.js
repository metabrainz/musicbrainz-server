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
import type {ReportWorkAnnotationT} from '../types';

const WorkAnnotationList = ({items, pager}: {items: $ReadOnlyArray<ReportWorkAnnotationT>, pager: PagerT}) => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Work')}</th>
          <th>{l('Annotation')}</th>
          <th style={{width: '10em'}}>{l('Last edited')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.work.gid}>
            <td>
              <EntityLink entity={item.work} />
            </td>
            <td dangerouslySetInnerHTML={{__html: item.text}} />
            <td>{item.created}</td>
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default WorkAnnotationList;
