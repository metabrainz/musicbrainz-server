/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {Artwork} from '../components/Artwork';
import EnterEdit from '../components/EnterEdit';
import EnterEditNote from '../components/EnterEditNote';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';
import EntityLink from '../static/scripts/common/components/EntityLink';

import ReleaseLayout from './ReleaseLayout';

type Props = {
  +$c: CatalystContextT,
  +artwork: ArtworkT,
  +form: ConfirmFormT,
  +release: ReleaseT,
};

const RemoveCoverArt = ({
  $c,
  artwork,
  form,
  release,
}: Props): React.Element<typeof ReleaseLayout> => {
  const title = l('Remove Cover Art');

  return (
    <ReleaseLayout $c={$c} entity={release} fullWidth title={title}>
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
      <form action={$c.req.uri} method="post">
        <EnterEditNote field={form.field.edit_note} />
        <EnterEdit form={form} />
      </form>
    </ReleaseLayout>
  );
};

export default RemoveCoverArt;
