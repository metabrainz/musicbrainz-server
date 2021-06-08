/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import GenreEditForm from './GenreEditForm';
import GenreLayout from './GenreLayout';
import type {GenreFormT} from './types';

type Props = {
  +$c: CatalystContextT,
  +form: GenreFormT,
  +genre: GenreT,
};

const EditGenre = ({
  $c,
  form,
  genre,
}: Props): React.Element<typeof GenreLayout> => (
  <GenreLayout
    entity={genre}
    fullWidth
    page="edit"
    title={l('Edit genre')}
  >
    <GenreEditForm $c={$c} form={form} />
  </GenreLayout>
);

export default EditGenre;
