/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink from '../static/scripts/common/components/EntityLink.js';
import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';

import GenreLayout from './GenreLayout.js';
import type {GenreDeleteFormT} from './types.js';

component DeleteGenre(entity as genre: GenreT, form: GenreDeleteFormT) {
  return (
    <GenreLayout
      entity={genre}
      fullWidth
      page="delete"
      title="Remove genre"
    >
      <h2>{'Remove genre'}</h2>
      <p>
        {exp.l_admin('Are you sure you want to remove the genre {genre}?',
                     {genre: <EntityLink entity={genre} />})}
      </p>

      <form method="post">
        <EnterEditNote field={form.field.edit_note} />
        <EnterEdit form={form} />
      </form>

    </GenreLayout>
  );
}

export default DeleteGenre;
