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
import * as manifest from '../static/manifest';
import GenreEditForm from '../static/scripts/genre/components/GenreEditForm';

import type {GenreFormT} from './types';

type Props = {
  +$c: CatalystContextT,
  +attrInfo: LinkAttrTypeOptionsT,
  +form: GenreFormT,
  +sourceEntity: {entityType: 'genre'},
  +typeInfo: LinkTypeOptionsT,
};

const CreateGenre = ({
  $c,
  attrInfo,
  form,
  sourceEntity,
  typeInfo,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Add a new genre')}>
    <div id="content">
      <h1>{l('Add a new genre')}</h1>
      <GenreEditForm
        $c={$c}
        attrInfo={attrInfo}
        form={form}
        sourceEntity={sourceEntity}
        typeInfo={typeInfo}
      />
    </div>
    {manifest.js('genre/components/GenreEditForm', {async: 'async'})}
  </Layout>
);

export default CreateGenre;
