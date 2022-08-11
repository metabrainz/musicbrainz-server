/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EnterEdit from '../components/EnterEdit.js';
import EnterEditNote from '../components/EnterEditNote.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';

import GenreLayout from './GenreLayout.js';
import type {GenreDeleteFormT} from './types.js';

type Props = {
  +$c: CatalystContextT,
  +entity: GenreT,
  +form: GenreDeleteFormT,
};

const DeleteGenre = ({
  $c,
  entity: genre,
  form,
}: Props): React.Element<typeof GenreLayout> => (
  <GenreLayout
    entity={genre}
    fullWidth
    page="delete"
    title={l('Remove genre')}
  >
    <h2>{l('Remove genre')}</h2>
    <p>
      {exp.l('Are you sure you want to remove the genre {genre}?',
             {genre: <EntityLink entity={genre} />})}
    </p>

    <form action={$c.req.uri} method="post">
      <EnterEditNote field={form.field.edit_note} />
      <EnterEdit form={form} />
    </form>

  </GenreLayout>
);

export default DeleteGenre;
