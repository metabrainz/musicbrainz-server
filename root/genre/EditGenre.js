/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import * as manifest from '../static/manifest';
import GenreEditForm from '../static/scripts/genre/components/GenreEditForm';

import GenreLayout from './GenreLayout';
import type {GenreFormT} from './types';

type Props = {
  +$c: CatalystContextT,
  +attrInfo: LinkAttrTypeOptionsT,
  +entity: GenreT,
  +form: GenreFormT,
  +sourceEntity: GenreT,
  +typeInfo: LinkTypeOptionsT,
};

const EditGenre = ({
  $c,
  attrInfo,
  entity,
  form,
  sourceEntity,
  typeInfo,
}: Props): React.Element<typeof GenreLayout> => (
  <GenreLayout
    entity={entity}
    fullWidth
    page="edit"
    title={l('Edit genre')}
  >
    <GenreEditForm
      $c={$c}
      attrInfo={attrInfo}
      form={form}
      sourceEntity={sourceEntity}
      typeInfo={typeInfo}
    />
    {manifest.js('genre/components/GenreEditForm', {async: 'async'})}
  </GenreLayout>
);

export default EditGenre;
