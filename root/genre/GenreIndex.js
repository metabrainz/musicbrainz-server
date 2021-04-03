/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import TagLink from '../static/scripts/common/components/TagLink';

import GenreLayout from './GenreLayout';

type Props = {
  +genre: GenreT,
};

const GenreIndex = ({
  genre,
}: Props): React.Element<typeof GenreLayout> => (
  <GenreLayout
    entity={genre}
    page="index"
    title={l('Genre information')}
  >
    <h2>{l('Associated tags')}</h2>
    <table className="details">
      <tr>
        <th>{addColonText(l('Primary tag'))}</th>
        <td><TagLink tag={genre.name} /></td>
      </tr>
    </table>
  </GenreLayout>
);

export default GenreIndex;
