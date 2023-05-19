/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import PaginatedResults from '../../components/PaginatedResults.js';
import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import bracketed from '../../static/scripts/common/utility/bracketed.js';
import type {ReportLabelUrlT} from '../types.js';

import RemovedUrlRow from './RemovedUrlRow.js';

type Props = {
  +items: $ReadOnlyArray<ReportLabelUrlT>,
  +pager: PagerT,
};

const LabelUrlList = ({
  items,
  pager,
}: Props): React$Element<typeof PaginatedResults> => {
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
          {items.map((item, index) => {
            if (!item.url) {
              return <RemovedUrlRow colSpan="2" index={index} />;
            }

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
