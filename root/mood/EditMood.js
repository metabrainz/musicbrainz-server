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
import MoodEditForm from '../static/scripts/mood/components/MoodEditForm';

import MoodLayout from './MoodLayout';
import type {MoodFormT} from './types';

type Props = {
  +$c: CatalystContextT,
  +attrInfo: LinkAttrTypeOptionsT,
  +entity: MoodT,
  +form: MoodFormT,
  +sourceEntity: MoodT,
  +typeInfo: LinkTypeOptionsT,
};

const EditMood = ({
  $c,
  attrInfo,
  entity,
  form,
  sourceEntity,
  typeInfo,
}: Props): React.Element<typeof MoodLayout> => (
  <MoodLayout
    entity={entity}
    fullWidth
    page="edit"
    title={l('Edit mood')}
  >
    <MoodEditForm
      $c={$c}
      attrInfo={attrInfo}
      form={form}
      sourceEntity={sourceEntity}
      typeInfo={typeInfo}
    />
    {manifest.js('mood/components/MoodEditForm', {async: 'async'})}
  </MoodLayout>
);

export default EditMood;
