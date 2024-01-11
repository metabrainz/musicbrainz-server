/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import loopParity from '../../utility/loopParity.js';

type Props = {
  +entity: CoreEntityT,
  +relationshipCredits: $ReadOnlyArray<string>,
};

const RelationshipCreditList = ({
  entity,
  relationshipCredits,
}: Props): React.Element<typeof React.Fragment> => {
  return (
    <>
      <h2>{l('Relationship credits')}</h2>
      <p>
        {exp.l(
          `This is a list of all the different ways {artist} is credited
           in relationships.`,
          {
            artist: <EntityLink entity={entity} />,
          },
        )}
      </p>

      <table className="tbl artist-credits">
        <thead>
          <tr>
            <th>
              {l('Name')}
            </th>
          </tr>
        </thead>
        <tbody>
          {relationshipCredits.map((credit, index) => (
            <tr className={loopParity(index)} key={'rel-credit-' + index}>
              <td>
                {credit}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  );
};

export default RelationshipCreditList;
