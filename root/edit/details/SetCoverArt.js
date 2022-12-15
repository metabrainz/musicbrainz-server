/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import manifest from '../../static/manifest.mjs';
import {Artwork} from '../../static/scripts/common/components/Artwork.js';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink.js';
import ReleaseEvents
  from '../../static/scripts/common/components/ReleaseEvents.js';
import commaList from '../../static/scripts/common/i18n/commaList.js';

component SetCoverArt(edit: SetCoverArtEditT) {
  const display = edit.display_data;
  const oldArt = display.artwork.old;
  const newArt = display.artwork.new;

  return (
    <table className="details set-cover-art">
      <tr>
        <th>{addColonText(l('Release group'))}</th>
        <td>
          <DescriptiveLink entity={display.release_group} />
        </td>
      </tr>

      <tr>
        <th>{lp('Old cover art:', 'singular')}</th>
        <td>
          {oldArt ? (
            <div className="editimage">
              <div className="cover-image">
                <Artwork artwork={oldArt} />
              </div>
              {oldArt.release ? (
                <p>
                  <DescriptiveLink entity={oldArt.release} />
                  <br />
                  <ReleaseEvents events={oldArt.release.events} />
                </p>
              ) : null}
              <p>
                {commaList(oldArt.types) || '-'}
                <br />
                {oldArt.comment}
              </p>
            </div>
          ) : display.isOldArtworkAutomatic ? (
            l(`The old image was selected automatically
               from the earliest release in the release group.`)
          ) : l(`We are unable to display this cover art.`)}
        </td>
      </tr>

      <tr>
        <th>{lp('New cover art:', 'singular')}</th>
        <td>
          {newArt ? (
            <div className="editimage">
              <div className="cover-image">
                <Artwork artwork={newArt} />
              </div>
              {newArt.release ? (
                <>
                  <DescriptiveLink entity={newArt.release} />
                  <br />
                  <ReleaseEvents events={newArt.release.events} />
                </>
              ) : null}
              <p>
                {commaList(newArt.types) || '-'}
                <br />
                {newArt.comment}
              </p>
            </div>
          ) : l(`We are unable to display this cover art.`)}
        </td>
      </tr>
      {manifest('common/components/ReleaseEvents', {async: 'async'})}
    </table>
  );
}

export default SetCoverArt;
