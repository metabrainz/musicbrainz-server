/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../../layout/index.js';
import formatEntityTypeName
  from '../../static/scripts/common/utility/formatEntityTypeName.js';
import RelationshipsHeader from '../RelationshipsHeader.js';

type Props = {
  +table: $ReadOnlyArray<$ReadOnlyArray<$ReadOnlyArray<string>>>,
  +types: $ReadOnlyArray<string>,
};

const TypesTable = ({table, types}: Props) => (
  <table className="wikitable">
    <tr>
      <th />
      {types.map(type => (
        <th key={type}>{formatEntityTypeName(type)}</th>
      ))}
    </tr>

    {table.map((row, index) => (
      <tr key={'row' + types[index]}>
        <th>{formatEntityTypeName(types[index])}</th>
        {types.map((type, index) => {
          const cellTypes = row[index];

          return (
            <td key={'cell' + index}>
              {cellTypes ? (
                <a href={'/relationships/' + cellTypes.join('-')}>
                  {texp.l(
                    '{type0}-{type1}',
                    {
                      type0: formatEntityTypeName(cellTypes[0]),
                      type1: formatEntityTypeName(cellTypes[1]),
                    },
                  )}
                </a>
              ) : null}
            </td>
          );
        })}
      </tr>
    ))}
  </table>
);

const RelationshipTypesList = ({
  table,
  types,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth noIcons title={l('Relationship Types')}>
    <div className="wikicontent" id="content">
      <RelationshipsHeader page="relationships" />
      <TypesTable table={table} types={types} />
    </div>
  </Layout>
);

export default RelationshipTypesList;
