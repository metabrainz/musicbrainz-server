/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {Artwork} from '../../components/Artwork';
import DescriptiveLink
  from '../../static/scripts/common/components/DescriptiveLink';
import ReleaseEvents
  from '../../static/scripts/common/components/ReleaseEvents';
import commaList from '../../static/scripts/common/i18n/commaList';

type Props = {
  +edit: SetCoverArtEditT,
};

const SetCoverArt = ({edit}: Props): React.Element<'table'> => {
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
        <th>{l('Old cover art:')}</th>
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
        <th>{l('New cover art:')}</th>
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
    </table>
  );
};

export default SetCoverArt;
