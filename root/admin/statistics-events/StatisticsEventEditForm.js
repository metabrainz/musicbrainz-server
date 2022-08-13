/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormCsrfToken from '../../components/FormCsrfToken.js';
import FormRowTextLong from '../../components/FormRowTextLong.js';
import FormSubmit from '../../components/FormSubmit.js';

import type {StatisticsEventFormT} from './types.js';

type PropsT = {
  +form: StatisticsEventFormT,
};

const StatisticsEventForm = ({
  form,
}: PropsT): React.Element<'form'> => (
  <form method="post">
    <FormCsrfToken form={form} />
    <div className="half-width">
      <fieldset>
        <legend>{l('Statistics event details')}</legend>
        <FormRowTextLong
          field={form.field.date}
          label={addColonText(l('Date'))}
          required
          uncontrolled
        />
        <FormRowTextLong
          field={form.field.title}
          label={addColonText(l('Title'))}
          required
          uncontrolled
        />
        <FormRowTextLong
          field={form.field.description}
          label={addColonText(l('Description'))}
          uncontrolled
        />
        <FormRowTextLong
          field={form.field.link}
          label={addColonText(l('Link'))}
          uncontrolled
        />
      </fieldset>
    </div>
    <div className="row no-label">
      <FormSubmit label={l('Submit')} />
    </div>
  </form>
);

export default StatisticsEventForm;
