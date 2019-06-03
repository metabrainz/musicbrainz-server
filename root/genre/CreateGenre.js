/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import Layout from '../layout';

import GenreEditForm from './GenreEditForm';
import type {GenreFormT} from './types';

const CreateGenre = ({form}: {form: GenreFormT}) => (
  <Layout fullWidth title={l('Add a new genre')}>
    <div id="content">
      <h1>{l('Add a new genre')}</h1>
      <GenreEditForm form={form} />
    </div>
  </Layout>
);

export default CreateGenre;
