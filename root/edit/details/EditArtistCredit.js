/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

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
      <tr>
        <th>{addColonText(l('Artist Credit'))}</th>
        <td className="old">
          <ExpandedArtistCredit artistCredit={display.artist_credit.old} />
        </td>
        <td className="new">
          <ExpandedArtistCredit artistCredit={display.artist_credit.new} />
        </td>
      </tr>
    </table>
  );
};

export default EditArtistCredit;
