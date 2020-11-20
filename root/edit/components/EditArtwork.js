/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {Artwork} from '../../components/Artwork.js';
import expand2html from '../../static/scripts/common/i18n/expand2html.js';
import entityHref from '../../static/scripts/common/utility/entityHref.js';

type Props = {
  +artwork: ArtworkT,
  +colSpan?: number,
  +entity: EventT | ReleaseT,
};

const EditArtwork = ({
  artwork,
  colSpan,
  entity,
}: Props): React$Element<'tr'> => {
  let historyMessage;
  let title;
  let className;
  if (entity.entityType === 'event') {
    historyMessage = entity.gid ? (
      expand2html(
        l(`We are unable to display history for this event
           art. For a current listing of event art, please see the
           {eventart|event's art page}.`),
        {eventart: entityHref(entity, 'event-art')},
      )
    ) : l('We are unable to display history for this piece of artwork.');
    title = addColonText(lp('Event art', 'singular'));
    className = 'edit-event-art';
  } else if (entity.entityType === 'release') {
    historyMessage = entity.gid ? (
      expand2html(
        l(`We are unable to display history for this cover
           art. For a current listing of cover art, please see the
           {coverart|release's cover art page}.`),
        {coverart: entityHref(entity, 'cover-art')},
      )
    ) : l('We are unable to display history for this piece of artwork.');
    title = addColonText(lp('Cover art', 'singular'));
    className = 'edit-cover-art';
  }

  return (
    <tr>
      <th>{title}</th>
      <td className={className} colSpan={colSpan ?? null}>
        <Artwork artwork={artwork} message={historyMessage} />
      </td>
    </tr>
  );
};

export default EditArtwork;
