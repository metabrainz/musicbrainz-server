/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormRowTextLong from '../components/FormRowTextLong';
import FormSubmit from '../components/FormSubmit';

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
    </div>
    <div className="row no-label">
      {/* TODO: Replace with 'Enter edit' with MBS-10165 */}
      <FormSubmit label={l('Submit')} />
    </div>
  </form>
);

export default GenreEditForm;
