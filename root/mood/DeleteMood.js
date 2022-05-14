/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EnterEdit from '../components/EnterEdit';
import EnterEditNote from '../components/EnterEditNote';
import EntityLink from '../static/scripts/common/components/EntityLink';

import MoodLayout from './MoodLayout';
import type {MoodDeleteFormT} from './types';

type Props = {
  +$c: CatalystContextT,
  +entity: MoodT,
  +form: MoodDeleteFormT,
};

const DeleteMood = ({
  $c,
  entity: mood,
  form,
}: Props): React.Element<typeof MoodLayout> => (
  <MoodLayout
    entity={mood}
    fullWidth
    page="delete"
    title={l('Remove mood')}
  >
    <h2>{l('Remove mood')}</h2>
    <p>
      {exp.l('Are you sure you want to remove the mood {mood}?',
             {mood: <EntityLink entity={mood} />})}
    </p>

    <form action={$c.req.uri} method="post">
      <EnterEditNote field={form.field.edit_note} />
      <EnterEdit form={form} />
    </form>

  </MoodLayout>
);

export default DeleteMood;
