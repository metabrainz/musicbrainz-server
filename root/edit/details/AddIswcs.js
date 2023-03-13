/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import CodeLink
  from '../../static/scripts/common/components/CodeLink.js';
import EntityLink
  from '../../static/scripts/common/components/EntityLink.js';

type Props = {
  +edit: AddIswcsEditT,
};

const AddIswcs = ({edit}: Props): React$Element<'table'> => {
  const additions = edit.display_data.additions;

  return (
    <table className="details add-iswcs">
      <tr>
        <th>{l('Additions:')}</th>
        <td>
          <ul>
            {additions.map(addition => (
              <li key={addition.iswc.iswc + '-' + addition.work.id}>
                {exp.l(
                  'ISWC {iswc} to {work}',
                  {
                    iswc: <CodeLink code={addition.iswc} key="iswc" />,
                    work: <EntityLink entity={addition.work} />,
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

export default AddIswcs;
