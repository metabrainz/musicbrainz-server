/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';

import GenreEditForm from './GenreEditForm';
import type {GenreFormT} from './types';

type Props = {
  +$c: CatalystContextT,
  +form: GenreFormT,
};

const CreateGenre = ({$c, form}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Add a new genre')}>
    <div id="content">
      <h1>{l('Add a new genre')}</h1>
      <GenreEditForm $c={$c} form={form} />
    </div>
  </Layout>
);

export default CreateGenre;
