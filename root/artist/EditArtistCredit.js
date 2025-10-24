/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import manifest from '../static/manifest.mjs';
import EditArtistCreditForm
  from '../static/scripts/artist/components/EditArtistCreditForm.js';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink.js';

import ArtistLayout from './ArtistLayout.js';
import type {EditArtistCreditFormT} from './types.js';

component EditArtistCredit(
  artist: ArtistT,
  artistCredit: ArtistCreditT,
  form: EditArtistCreditFormT,
) {
  const title = lp('Edit artist credit', 'header');

  return (
    <ArtistLayout
      entity={artist}
      fullWidth
      page="split"
      title={title}
    >
      <h2>{title}</h2>

      <div className="half-width">
        <p>
          {exp.l(
            `This form allows you to edit the artist credit “{ac}”.
             When the edit is accepted, all tracks, recordings, releases
             and release groups using this artist credit will be
             updated to use the new one.`,
            {ac: <ArtistCreditLink artistCredit={artistCredit} />},
          )}
        </p>
      </div>

      <EditArtistCreditForm
        artistCredit={artistCredit}
        form={form}
      />
      {manifest('artist/components/EditArtistCreditForm', {async: true})}
    </ArtistLayout>
  );
}

export default EditArtistCredit;
