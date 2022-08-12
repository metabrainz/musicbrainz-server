/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {Artwork} from '../components/Artwork.js';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';

import ReleaseLayout from './ReleaseLayout.js';

type Props = {
  +artwork: ArtworkT,
  +form: ConfirmFormT,
  +release: ReleaseT,
};

const RemoveCoverArt = ({
  artwork,
  form,
  release,
}: Props): React.Element<typeof ReleaseLayout> => {
  const title = l('Remove Cover Art');

  return (
    <ReleaseLayout entity={release} fullWidth title={title}>
      <h2>{title}</h2>
      <p>
        {exp.l(
          `Are you sure you wish to remove the below cover art
           from {release} by {artist}?`,
          {
            artist: <ArtistCreditLink artistCredit={release.artistCredit} />,
            release: <EntityLink entity={release} />,
          },
        )}
      </p>
      <p className="artwork">
        <Artwork artwork={artwork} />
      </p>
      <form method="post">
        <EnterEditNote field={form.field.edit_note} />
        <EnterEdit form={form} />
      </form>
    </ReleaseLayout>
  );
};

export default RemoveCoverArt;
