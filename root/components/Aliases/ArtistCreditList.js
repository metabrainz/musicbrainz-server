/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import bracketed from '../../static/scripts/common/utility/bracketed';
import loopParity from '../../utility/loopParity';

type Props = {
  +$c: CatalystContextT,
  +artistCredits: $ReadOnlyArray<{+id: number} & ArtistCreditT>,
  +entity: CoreEntityT,
};

const ArtistCreditList = ({
  $c,
  artistCredits,
  entity,
}: Props): React.Element<typeof React.Fragment> => {
  return (
    <>
      <h2>{l('Artist credits')}</h2>
      <p>
        {exp.l(
          `This is a list of all the different ways {artist} is credited
           in the database. View the {doc|artist credit documentation}
           for more details.`,
          {
            artist: <EntityLink entity={entity} />,
            doc: '/doc/Artist_Credits',
          },
        )}
      </p>

      <table className="tbl artist-credits">
        <thead>
          <tr>
            <th>
              {l('Name')}
            </th>
            {$c.user ? (
              <th className="actions">
                {l('Actions')}
              </th>
            ) : null}
          </tr>
        </thead>
        <tbody>
          {artistCredits.map((credit, index) => (
            <tr className={loopParity(index)} key={credit.id}>
              <td>
                <ArtistCreditLink artistCredit={credit} />
                {' '}
                <span className="small">
                  {bracketed(
                    <a href={`/artist-credit/${credit.id}`}>
                      {l('see uses')}
                    </a>,
                  )}
                </span>
              </td>
              {$c.user ? (
                <td className="actions">
                  <a href={`/artist/${entity.gid}/credit/${credit.id}/edit`}>
                    {credit.editsPending /*:: === true */
                      ? <span className="mp">{l('Edit')}</span>
                      : l('Edit')}
                  </a>
                </td>
              ) : null}
            </tr>
          ))}
        </tbody>
      </table>
    </>
  );
};

export default ArtistCreditList;
