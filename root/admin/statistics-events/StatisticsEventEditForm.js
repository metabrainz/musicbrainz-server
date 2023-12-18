/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FormCsrfToken
  from '../../static/scripts/edit/components/FormCsrfToken.js';
import FormRowTextLong
  from '../../static/scripts/edit/components/FormRowTextLong.js';
import FormSubmit from '../../static/scripts/edit/components/FormSubmit.js';

type PropsT = {
  +form: StatisticsEventFormT,
};

const StatisticsEventForm = ({
  form,
}: PropsT): React$Element<'form'> => (
  <form method="post">
    <FormCsrfToken form={form} />
    <div className="half-width">
      <fieldset>
        <legend>{'Statistics event details'}</legend>
        <FormRowTextLong
          field={form.field.date}
          label="Date:"
          required
          uncontrolled
        />
        <FormRowTextLong
          field={form.field.title}
          label="Title:"
          required
          uncontrolled
        />
        <FormRowTextLong
          field={form.field.description}
          label="Description:"
          uncontrolled
        />
        <FormRowTextLong
          field={form.field.link}
          label="Link:"
          uncontrolled
        />
      </fieldset>
    </div>
    <div className="row no-label">
      <FormSubmit label="Submit" />
    </div>
  </form>
);

export default StatisticsEventForm;
