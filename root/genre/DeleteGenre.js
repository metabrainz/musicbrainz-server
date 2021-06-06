/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormSubmit from '../components/FormSubmit';
import EntityLink from '../static/scripts/common/components/EntityLink';

import GenreLayout from './GenreLayout';

type Props = {
  +$c: CatalystContextT,
  +genre: GenreT,
};

const DeleteGenre = ({
  $c,
  genre,
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
      <FormSubmit label={l('Remove genre')} />
    </form>

  </GenreLayout>
);

export default DeleteGenre;
