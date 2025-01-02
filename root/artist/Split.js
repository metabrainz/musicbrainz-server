/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink
  from '../static/scripts/common/components/EntityLink.js';
import entityHref from '../static/scripts/common/utility/entityHref.js';
import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';

import ArtistLayout from './ArtistLayout.js';

type EditArtistCreditFormT = ReadOnlyFormT<{
  +artist_credit: ReadOnlyFieldT<ArtistCreditT>,
  +edit_note: ReadOnlyFieldT<string>,
  +make_votable: ReadOnlyFieldT<boolean>,
  +preview: ReadOnlyFieldT<string>,
}>;

type Props = {
  +artist: ArtistT,
  +collaborators: $ReadOnlyArray<ArtistT>,
  +form: EditArtistCreditFormT,
  +inUse: boolean,
};

const Split = ({
  artist,
  collaborators,
  form,
  inUse,
}: Props): React$Element<typeof ArtistLayout> => (
  <ArtistLayout
    entity={artist}
    fullWidth
    page="split"
    title={l('Split Artist')}
  >
    <h2>{l('Split Into Separate Artists')}</h2>

    {inUse ? (
      <form method="post">
        <div className="half-width">
          <p>
            {exp.l(
              `This form allows you to split {artist} into separate artists.
               When the edit is accepted, existing artist credits will be
               updated, and collaboration relationships will be removed`,
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

          <fieldset>
            <legend>{l('New Artist Credit')}</legend>
            <div id="artist-credit-editor" />
          </fieldset>

          <EnterEditNote field={form.field.edit_note} />

          <EnterEdit form={form} />
        </div>
      </form>
    ) : (
      <p>
        {exp.l(
          `There are no recordings, release groups, releases or tracks
           credited to only {name}. If you are trying to remove {name}, please
           edit all artist credits at the bottom of the {alias_uri|aliases}
           tab and remove all existing {rel_uri|relationships} instead,
           which will allow ModBot to automatically remove this artist
           in the upcoming days.`,
          {
            alias_uri: entityHref(artist, 'aliases'),
            name: <EntityLink entity={artist} />,
            rel_uri: entityHref(artist, 'relationships'),
          },
        )}
      </p>
    )}
  </ArtistLayout>
);

export default Split;
