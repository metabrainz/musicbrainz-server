/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../../layout/index.js';
import formatEntityTypeName
  from '../../static/scripts/common/utility/formatEntityTypeName.js';
import RelationshipsHeader from '../RelationshipsHeader.js';

component TypesTable(
  table: $ReadOnlyArray<$ReadOnlyArray<$ReadOnlyArray<string>>>,
  types: $ReadOnlyArray<string>,
  usedTypes: {+[pairString: string]: 1},
) {
  return (
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
            const typePair = cellTypes ? cellTypes.join('-') : '';
            const inUse = typePair in usedTypes;

            return (
              <td
                className={inUse ? '' : 'unused-reltype-pair'}
                key={'cell' + index}
                title={inUse ? '' : l('This pair has no relationship types.')}
              >
                {cellTypes ? (
                  <a href={'/relationships/' + typePair}>
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
}

component RelationshipTypesList(...props: React.PropsOf<TypesTable>) {
  return (
    <Layout fullWidth noIcons title={l('Relationship types')}>
      <div className="wikicontent" id="content">
        <RelationshipsHeader page="relationships" />
        <TypesTable {...props} />
      </div>
    </Layout>
  );
}

export default RelationshipTypesList;
