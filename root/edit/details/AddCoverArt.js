/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EditArtwork from '../components/EditArtwork';
import commaOnlyList from '../../static/scripts/common/i18n/commaOnlyList';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';

type AddCoverArtEditT = {
  ...EditT,
  +display_data: {
    +artwork: ArtworkT,
    +position: number,
    +release: ReleaseT,
  },
};

type Props = {
  +edit: AddCoverArtEditT,
};

const AddCoverArt = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;

  return (
    <table className="details add-cover-art">
      <tr>
        <th>{addColonText(l('Release'))}</th>
        <td>
          <DescriptiveLink entity={display.release} />
        </td>
      </tr>

      {display.artwork.types?.length ? (
        <tr>
          <th>{l('Types:')}</th>
          <td>
            {commaOnlyList(display.artwork.types.map(
              type => lp_attributes(type, 'cover_art_type'),
            ))}
          </td>
        </tr>
      ) : null}

      <tr>
        <th>{l('Filename:')}</th>
        <td>
          <code>
            {'mbid-' + display.release.gid + '-' +
              display.artwork.id + '.' + display.artwork.suffix}
          </code>
        </td>
      </tr>

      {display.artwork.comment ? (
        <tr>
          <th>{l('Comment:')}</th>
          <td>{display.artwork.comment}</td>
        </tr>
      ) : null}

      <EditArtwork artwork={display.artwork} release={display.release} />
    </table>
  );
};

export default AddCoverArt;
