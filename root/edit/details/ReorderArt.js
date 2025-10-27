/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {Artwork} from '../../static/scripts/common/components/Artwork.js';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import expand2html from '../../static/scripts/common/i18n/expand2html.js';
import entityHref from '../../static/scripts/common/utility/entityHref.js';

component ReorderArt(
  archiveName: 'cover' | 'event',
  edit:
    | ReorderCoverArtEditT
    | ReorderEventArtEditT,
  entityType: 'event' | 'release',
  formattedEntityType: string,
) {
  const display = edit.display_data;
  // $FlowFixMe[prop-missing]
  const entity = display[entityType];
  const oldArt = display.old;
  const newArt = display.new;
  const isMismatched = display.old.length !== display.new.length;

  const historyMessage = entity.gid ? (
    expand2html(
      l(`We are unable to display history for this image.
         See {artpage|all current images}.`),
      {artpage: entityHref(entity, archiveName + '-art')},
    )
  ) : l('We are unable to display history for this image.');

  return (
    <table className={'details reorder-' + archiveName + '-art'}>
      <tr>
        <th>{addColonText(formattedEntityType)}</th>
        <td>
          {/* $FlowFixMe[prop-missing] */}
          <DescriptiveLink entity={entity} />
        </td>
      </tr>

      <tr>
        <th>{l('Old positions:')}</th>
        <td>
          {isMismatched ? (
            l('An error occurred while loading this edit.')
          ) : (
            oldArt.map(art => (
              <div className="thumb-position" key={'old-' + art.id}>
                <Artwork artwork={art} message={historyMessage} />
              </div>
            ))
          )}
        </td>
      </tr>


      <tr>
        <th>{l('New positions:')}</th>
        <td>
          {isMismatched ? (
            l('An error occurred while loading this edit.')
          ) : (
            newArt.map((art, index) => (
              <div
                className={'thumb-position' +
                          (art.id === oldArt[index].id ? '' : ' moved')}
                key={'new-' + art.id}
              >
                <Artwork artwork={art} message={historyMessage} />
              </div>
            ))
          )}
        </td>
      </tr>
    </table>
  );
}

export default ReorderArt;
