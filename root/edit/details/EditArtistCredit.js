/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistCreditUsageLink
  from '../../static/scripts/common/components/ArtistCreditUsageLink';
import ExpandedArtistCredit from
  '../../static/scripts/common/components/ExpandedArtistCredit';

type EditArtistCreditEditT = {
  ...EditT,
  +display_data: {
    +artist_credit: CompT<ArtistCreditT>,
  },
};

type Props = {
  +edit: EditArtistCreditEditT,
};

const EditArtistCredit = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;

  return (
    <table className="details split-artist">
      <tbody>
        <tr>
          <th>{addColonText(l('Artist Credit'))}</th>
          <td className="old">
            <ExpandedArtistCredit artistCredit={display.artist_credit.old} />
          </td>
          <td className="new">
            <ExpandedArtistCredit artistCredit={display.artist_credit.new} />
          </td>
        </tr>
        {edit.is_open && display.artist_credit.old.id != null ? (
          <tr>
            <th />
            <td colSpan="2">
              <ArtistCreditUsageLink
                artistCredit={display.artist_credit.old}
                content={l(
                  'See all uses of the artist credit being changed.',
                )}
              />
            </td>
          </tr>
        ) : null}
      </tbody>
    </table>
  );
};

export default EditArtistCredit;
