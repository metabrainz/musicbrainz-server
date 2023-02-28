/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import * as manifest from '../static/manifest.mjs';
import GenreEditForm
  from '../static/scripts/genre/components/GenreEditForm.js';

import GenreLayout from './GenreLayout.js';
import type {GenreFormT} from './types.js';

type Props = {
  +entity: GenreT,
  +form: GenreFormT,
};

const EditGenre = ({
  entity,
  form,
}: Props): React.Element<typeof GenreLayout> => (
  <GenreLayout
    entity={entity}
    fullWidth
    page="edit"
    title={l('Edit genre')}
  >
    <GenreEditForm form={form} />
    {manifest.js('genre/components/GenreEditForm', {async: 'async'})}
    {manifest.js('relationship-editor', {async: 'async'})}
  </GenreLayout>
);

export default EditGenre;
