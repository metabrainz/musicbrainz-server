/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseLayout from '../release/ReleaseLayout.js';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink.js';
import CDTocLink
  from '../static/scripts/common/components/CDTocLink.js';
import EntityLink
  from '../static/scripts/common/components/EntityLink.js';
import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';

type RemoveDiscIdProps = {
  +form: ConfirmFormT,
  +mediumCDToc: MediumCDTocT,
  +release: ReleaseT,
};

const RemoveDiscId = ({
  form,
  mediumCDToc,
  release,
}: RemoveDiscIdProps): React$Element<typeof ReleaseLayout> => (
  <ReleaseLayout entity={release} fullWidth title={l('Remove Disc ID')}>
    <h2>{l('Remove Disc ID')}</h2>

    <ul>
      <li>
        {exp.l(
          `Are you sure you want to remove the disc ID <code>{discid}</code>
           from the release {release} by {artist}?`,
          {
            artist: <ArtistCreditLink artistCredit={release.artistCredit} />,
            discid: <CDTocLink cdToc={mediumCDToc.cdtoc} />,
            release: <EntityLink entity={release} />,
          },
        )}
      </li>
      <li>
        {exp.l(
          `You need to be certain that this disc ID was added to this release
           erroneously, since a release can have multiple valid disc IDs,
           and each disc ID can belong to more than one release.
           For more in-depth information about this topic,
           please see our {doc|CD submission guide}.`,
          {doc: '/doc/How_to_Add_Disc_IDs'},
        )}
      </li>
    </ul>

    <form method="post">
      <EnterEditNote field={form.field.edit_note} />
      <EnterEdit form={form} />
    </form>
  </ReleaseLayout>
);

export default RemoveDiscId;
