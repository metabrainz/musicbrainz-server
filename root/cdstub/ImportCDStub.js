/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults.js';
import type {SearchResultT} from '../search/types.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import FormRowText from '../static/scripts/edit/components/FormRowText.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';
import InlineSubmitButton
  from '../static/scripts/edit/components/InlineSubmitButton.js';

import CDStubLayout from './CDStubLayout.js';

type Props = {
  +artists: $ReadOnlyArray<SearchResultT<ArtistT>>,
  +cdstub: CDStubT,
  +form: SearchFormT,
  +pager: PagerT,
};

const ImportCDStub = ({
  artists,
  cdstub,
  form,
  pager,
}: Props): React$Element<typeof CDStubLayout> => (
  <CDStubLayout entity={cdstub} page="import">
    <h2>{l('Import CD Stub')}</h2>
    <p>
      {l(`Please search for the artist you wish
          to create a new release for:`)}
    </p>

    <form method="post">
      <FormRowText
        field={form.field.query}
        label={addColonText(l('Artist'))}
        required
        uncontrolled
      >
        <InlineSubmitButton label={l('Search')} />
      </FormRowText>
    </form>

    <form action="/release/add" method="post">
      <input name="name" type="hidden" value={cdstub.title} />
      <input name="barcode" type="hidden" value={cdstub.barcode} />
      <input name="mediums.0.toc" type="hidden" value={cdstub.toc} />
      <input name="mediums.0.format" type="hidden" value="CD" />

      {cdstub.tracks.map((track, index) => (
        <React.Fragment key={index}>
          <input
            name={`mediums.0.track.${index}.name`}
            type="hidden"
            value={track.title}
          />
          <input
            name={`mediums.0.track.${index}.length`}
            type="hidden"
            value={track.length}
          />
          {track.artist ? (
            <input
              name={`mediums.0.track.${index}.artist_credit.names.0.name`}
              type="hidden"
              value={track.artist}
            />
          ) : null}
        </React.Fragment>
      ))}

      <PaginatedResults pager={pager}>
        <ul>
          {artists.map((artist, index) => (
            <li key={index}>
              <input
                id="id.artist_credit.names.0.mbid"
                name="artist_credit.names.0.mbid"
                type="radio"
                value={artist.entity.gid}
              />
              {' '}
              <label htmlFor="id.artist_credit.names.0.mbid">
                <EntityLink entity={artist.entity} />
              </label>
            </li>
          ))}
        </ul>
      </PaginatedResults>

      <FormSubmit label={l('Import CD stub')} />
    </form>
  </CDStubLayout>
);

export default ImportCDStub;
