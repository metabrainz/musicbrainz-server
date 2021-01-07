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

type RemoveCoverArtEditT = {
  ...EditT,
  +display_data: {
    +artwork: ArtworkT,
    +release: ReleaseT,
  },
};

type Props = {
  +edit: RemoveCoverArtEditT,
};

const RemoveCoverArt = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;

  return (
    <table className="details remove-cover-art">
      <tr>
        <th>{addColonText(l('Release'))}</th>
        <td>
          <DescriptiveLink entity={display.release} />
        </td>
      </tr>

      <tr>
        <th>{l('Types:')}</th>
        <td>
          {display.artwork.types?.length ? (
            commaOnlyList(display.artwork.types.map(
              type => lp_attributes(type, 'cover_art_type'),
            ))
          ) : lp('(none)', 'type')}
        </td>
      </tr>

      {nonEmpty(display.artwork.filename) ? (
        <tr>
          <th>{l('Filename:')}</th>
          <td>
            <code>
              {display.artwork.filename}
            </code>
          </td>
        </tr>
      ) : null}

      <tr>
        <th>{l('Comment:')}</th>
        <td>
          {nonEmpty(display.artwork.comment)
            ? display.artwork.comment
            : lp('(none)', 'comment')}
        </td>
      </tr>

      <EditArtwork artwork={display.artwork} release={display.release} />
    </table>
  );
};

export default RemoveCoverArt;
