/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import manifest from '../static/manifest.mjs';
import GenreEditForm
  from '../static/scripts/genre/components/GenreEditForm.js';

import GenreLayout from './GenreLayout.js';
import type {GenreFormT} from './types.js';

component EditGenre(entity: GenreT, form: GenreFormT) {
  return (
    <GenreLayout
      entity={entity}
      fullWidth
      page="edit"
      title="Edit genre"
    >
      <GenreEditForm form={form} />
      {manifest('genre/components/GenreEditForm', {async: true})}
      {manifest('relationship-editor', {async: true})}
    </GenreLayout>
  );
}

export default EditGenre;
