/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {Artwork} from '../../components/Artwork.js';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import expand2html from '../../static/scripts/common/i18n/expand2html.js';
import entityHref from '../../static/scripts/common/utility/entityHref.js';

type Props = {
  +archiveName: 'cover' | 'event',
  +edit:
    | ReorderCoverArtEditT
    | ReorderEventArtEditT,
  +entityType: 'event' | 'release',
  +formattedEntityType: string,
};

const ReorderArt = ({
  archiveName,
  edit,
  entityType,
  formattedEntityType,
}: Props): React$Element<'table'> => {
  const display = edit.display_data;
  const oldArt = display.old;
  const newArt = display.new;
  let historyMessage;

  if (entityType === 'event') {
    historyMessage = expand2html(
      l(`We are unable to display history for this event
         art. For a current listing of evebt art, please see the
         {eventart|events's art page}.`),
      // $FlowIgnore[incompatible-call]
      {eventart: entityHref(display.event, 'event-art')},
    );
  } else if (entityType === 'release') {
    historyMessage = expand2html(
      l(`We are unable to display history for this cover
         art. For a current listing of cover art, please see the
         {coverart|release's cover art page}.`),
      // $FlowIgnore[incompatible-call]
      {coverart: entityHref(display.release, 'cover-art')},
    );
  }

  return (
    <table className={'details reorder-' + archiveName + '-art'}>
      <tr>
        <th>{addColonText(formattedEntityType)}</th>
        <td>
          {/* $FlowIgnore[prop-missing] */}
          <DescriptiveLink entity={display[entityType]} />
        </td>
      </tr>

      <tr>
        <th>{l('Old positions:')}</th>
        <td>
          {oldArt.map(art => (
            <div className="thumb-position" key={'old-' + art.id}>
              <Artwork artwork={art} message={historyMessage} />
            </div>
          ))}
        </td>
      </tr>


      <tr>
        <th>{l('New positions:')}</th>
        <td>
          {newArt.map((art, index) => (
            <div
              className={'thumb-position' +
                         (art.id === oldArt[index].id ? '' : ' moved')}
              key={'new-' + art.id}
            >
              <Artwork artwork={art} message={historyMessage} />
            </div>
          ))}
        </td>
      </tr>
    </table>
  );
};

export default ReorderArt;
