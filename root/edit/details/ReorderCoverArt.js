/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {Artwork} from '../../components/Artwork.js';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import expand2html from '../../static/scripts/common/i18n/expand2html.js';
import entityHref from '../../static/scripts/common/utility/entityHref.js';

type Props = {
  +edit: ReorderCoverArtEditT,
};

const ReorderCoverArt = ({edit}: Props): React.Element<'table'> => {
  const display = edit.display_data;
  const oldArt = display.old;
  const newArt = display.new;
  const historyMessage = expand2html(
    l(`We are unable to display history for this cover
        art. For a current listing of cover art, please see the
        {coverart|release's cover art page}.`),
    {coverart: entityHref(display.release, 'cover-art')},
  );

  return (
    <table className="details reorder-cover-art">
      <tr>
        <th>{addColonText(l('Release'))}</th>
        <td>
          <DescriptiveLink entity={display.release} />
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

export default ReorderCoverArt;
