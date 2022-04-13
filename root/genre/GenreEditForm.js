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
import FormRowTextLong from '../components/FormRowTextLong';

import type {GenreFormT} from './types';

type Props = {
  +$c: CatalystContextT,
  +form: GenreFormT,
};

const GenreEditForm = ({
  $c,
  form,
}: Props): React.Element<'form'> => (
  <form action={$c.req.uri} method="post">
    <div className="half-width">
      <fieldset>
        <legend>{l('Genre details')}</legend>
        <FormRowTextLong
          field={form.field.name}
          label={addColonText(l('Name'))}
          required
          uncontrolled
        />
        <FormRowTextLong
          field={form.field.comment}
          label={addColonText(l('Disambiguation'))}
          uncontrolled
        />
      </fieldset>
      <EnterEditNote field={form.field.edit_note} />
      <EnterEdit form={form} />
    </div>
  </form>
);

export default GenreEditForm;
