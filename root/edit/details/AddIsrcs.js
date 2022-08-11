/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CodeLink
  from '../../static/scripts/common/components/CodeLink.js';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';

type Props = {
  +edit: AddIsrcsEditT,
};

const AddIsrcs = ({edit}: Props): React.Element<'table'> => {
  const additions = edit.display_data.additions;
  const clientVersion = edit.display_data.client_version;

  return (
    <table className="details add-isrcs">
      {clientVersion == null ? null : (
        <tr>
          <th>{l('Client:')}</th>
          <td>{clientVersion || lp('(unknown)', 'isrc client')}</td>
        </tr>
      )}

      <tr>
        <th>{l('Additions:')}</th>
        <td>
          <ul>
            {additions.map(addition => (
              <li key={addition.isrc.isrc + '-' + addition.recording.id}>
                {exp.l(
                  'ISRC {isrc} to {recording}',
                  {
                    isrc: <CodeLink code={addition.isrc} key="isrc" />,
                    recording: (
                      <DescriptiveLink entity={addition.recording} />
                    ),
                  },
                )}
              </li>
            ))}
          </ul>
        </td>
      </tr>
    </table>
  );
};

export default AddIsrcs;
