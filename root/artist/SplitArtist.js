/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import manifest from '../static/manifest.mjs';
import EditArtistCreditForm
  from '../static/scripts/artist/components/EditArtistCreditForm.js';
import EntityLink
  from '../static/scripts/common/components/EntityLink.js';
import entityHref from '../static/scripts/common/utility/entityHref.js';

import ArtistLayout from './ArtistLayout.js';
import type {EditArtistCreditFormT} from './types.js';

component SplitArtist(
  artist: ArtistT,
  artistCredit: ArtistCreditT,
  collaborators: $ReadOnlyArray<ArtistT>,
  form: EditArtistCreditFormT,
  inUse: boolean,
) {
  return (
    <ArtistLayout
      entity={artist}
      fullWidth
      page="split"
      title={l('Split artist')}
    >
      <h2>{l('Split into separate artists')}</h2>

      {inUse ? (
        <>
          <div className="half-width">
            <p>
              {exp.l(
                `This form allows you to split {artist} into separate artists.
                 When the edit is accepted, existing artist credits will be
                 updated, and collaboration relationships will be removed.`,
                {artist: <EntityLink entity={artist} />},
              )}
            </p>

            {collaborators.length ? (
              <>
                <h3>{addColonText(l('Collaborators on this artist'))}</h3>
                <ul>
                  {collaborators.map((collaborator, index) => (
                    <li key={index}>
                      <EntityLink entity={collaborator} />
                    </li>
                  ))}
                </ul>
              </>
            ) : null}
          </div>
          <EditArtistCreditForm
            artistCredit={artistCredit}
            form={form}
          />
        </>
      ) : (
        <p>
          {exp.l(
            `There are no recordings, release groups, releases or tracks
             credited to only {name}. If you are trying to remove {name},
             please edit all artist credits at the bottom of the
             {alias_uri|aliases} tab and remove all existing
             {rel_uri|relationships} instead, which will allow ModBot
             to automatically remove this artist in the upcoming days.`,
            {
              alias_uri: entityHref(artist, 'aliases'),
              name: <EntityLink entity={artist} />,
              rel_uri: entityHref(artist, 'relationships'),
            },
          )}
        </p>
      )}
      {manifest('artist/components/EditArtistCreditForm', {async: true})}
    </ArtistLayout>
  );
}

export default SplitArtist;
