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
import Annotation from '../static/scripts/common/components/Annotation.js';
import Relationships
  from '../static/scripts/common/components/Relationships.js';
import TagLink from '../static/scripts/common/components/TagLink.js';
import WikipediaExtract
  from '../static/scripts/common/components/WikipediaExtract.js';

import GenreLayout from './GenreLayout.js';

type Props = {
  +genre: GenreT,
  +numberOfRevisions: number,
  +wikipediaExtract: WikipediaExtractT | null,
};

const GenreIndex = ({
  genre,
  numberOfRevisions,
  wikipediaExtract,
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
    <WikipediaExtract
      cachedWikipediaExtract={wikipediaExtract}
      entity={genre}
    />
    <Annotation
      annotation={genre.latest_annotation}
      collapse
      entity={genre}
      numberOfRevisions={numberOfRevisions}
    />
    <Relationships source={genre} />
    {manifest.js('genre/index', {async: 'async'})}
  </GenreLayout>
);

export default GenreIndex;
