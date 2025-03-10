/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {Artwork} from '../../static/scripts/common/components/Artwork.js';
import expand2html from '../../static/scripts/common/i18n/expand2html.js';
import entityHref from '../../static/scripts/common/utility/entityHref.js';

component EditArtwork(
  artwork: ArtworkT,
  colSpan?: number,
  entity: EventT | ReleaseT,
) {
  let title = '';
  let archiveName = '';
  if (entity.entityType === 'event') {
    archiveName = 'event';
    title = addColonText(lp('Event art', 'singular'));
  } else if (entity.entityType === 'release') {
    archiveName = 'cover';
    title = addColonText(lp('Cover art', 'singular'));
  }

  const className = `edit-${archiveName}-art`;
  const historyMessage = entity.gid ? (
    expand2html(
      l(`We are unable to display history for this image.
         See {artpage|all current images}.`),
      {artpage: entityHref(entity, archiveName + '-art')},
    )
  ) : l('We are unable to display history for this image.');

  return (
    <tr>
      <th>{title}</th>
      <td className={className} colSpan={colSpan ?? null}>
        <Artwork artwork={artwork} message={historyMessage} />
      </td>
    </tr>
  );
}

export default EditArtwork;
