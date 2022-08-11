/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {Artwork} from '../../components/Artwork.js';
import expand2html from '../../static/scripts/common/i18n/expand2html.js';
import entityHref from '../../static/scripts/common/utility/entityHref.js';

type Props = {
  +artwork: ArtworkT,
  +colSpan?: number,
  +release: ReleaseT,
};

const EditArtwork = ({
  artwork,
  colSpan,
  release,
}: Props): React.Element<'tr'> => {
  const historyMessage = release.gid ? (
    expand2html(
      l(`We are unable to display history for this cover
         art. For a current listing of cover art, please see the
         {coverart|release's cover art page}.`),
      {coverart: entityHref(release, 'cover-art')},
    )
  ) : l('We are unable to display history for this cover art.');

  return (
    <tr>
      <th>{l('Cover art:')}</th>
      <td className="edit-cover-art" colSpan={colSpan ?? null}>
        <Artwork artwork={artwork} message={historyMessage} />
      </td>
    </tr>
  );
};

export default EditArtwork;
