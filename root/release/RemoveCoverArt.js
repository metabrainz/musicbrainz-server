/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {Artwork} from '../static/scripts/common/components/Artwork.js';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink.js';
import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';

import ReleaseLayout from './ReleaseLayout.js';

component RemoveCoverArt(
  artwork: ReleaseArtT,
  form: ConfirmFormT,
  release: ReleaseT,
) {
  const title = lp('Remove cover art', 'singular, header');

  return (
    <ReleaseLayout entity={release} fullWidth title={title}>
      <h2>{title}</h2>
      <p>
        {exp.l(
          `Are you sure you wish to remove the image below from {entity}?`,
          {entity: <DescriptiveLink entity={release} />},
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
}

export default RemoveCoverArt;
