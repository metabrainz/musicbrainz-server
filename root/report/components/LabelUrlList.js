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
import bracketed from '../../static/scripts/common/utility/bracketed';
import type {ReportLabelUrlT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportLabelUrlT>,
  +pager: PagerT,
};

const LabelUrlList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  let lastGID: string = '';
  let currentGID: string = '';

  return (
    <PaginatedResults pager={pager}>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('URL')}</th>
            <th>{l('Label')}</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item) => {
            lastGID = currentGID;
            currentGID = item.url.gid;

            return (
              <>
                {lastGID === item.url.gid ? null : (
                  <tr className="even" key={item.url.gid}>
                    <td colSpan="2">
                      <a href={item.url.name}>
                        {item.url.name}
                      </a>
                      {' '}
                      {bracketed(
                        <a href={'/url/' + item.url.gid}>
                          {item.url.gid}
                        </a>,
                      )}
                    </td>
                  </tr>
                )}
                {item.label ? (
                  <tr key={item.label.gid}>
                    <td />
                    <td>
                      <EntityLink entity={item.label} />
                    </td>
                  </tr>
                ) : (
                  <tr key={`removed-${item.label_id}`}>
                    <td />
                    <td>
                      {l('This label no longer exists.')}
                    </td>
                  </tr>
                )}
              </>
            );
          })}
        </tbody>
      </table>
    </PaginatedResults>
  );
};

export default LabelUrlList;
