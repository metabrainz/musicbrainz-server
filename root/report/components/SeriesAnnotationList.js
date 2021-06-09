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
import type {ReportSeriesAnnotationT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportSeriesAnnotationT>,
  +pager: PagerT,
};

const SeriesAnnotationList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Series')}</th>
          <th>{l('Annotation')}</th>
          <th style={{width: '10em'}}>{l('Last edited')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.series_id}>
            {item.series ? (
              <td>
                <EntityLink entity={item.series} />
              </td>
            ) : (
              <td>
                {l('This series no longer exists.')}
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

export default SeriesAnnotationList;
