/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';
import * as manifest from '../static/manifest.mjs';
import GenreEditForm
  from '../static/scripts/genre/components/GenreEditForm.js';

import type {GenreFormT} from './types.js';

type Props = {
  +form: GenreFormT,
};

const CreateGenre = ({
  form,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Add a new genre')}>
    <div id="content">
      <h1>{l('Add a new genre')}</h1>
      <GenreEditForm form={form} />
    </div>
    {manifest.js('genre/components/GenreEditForm', {async: 'async'})}
    {manifest.js('relationship-editor', {async: 'async'})}
  </Layout>
);

export default CreateGenre;
