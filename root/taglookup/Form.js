/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import FormRow from '../components/FormRow';
import FormRowText from '../components/FormRowText';
import FormRowTextLong from '../components/FormRowTextLong';
import FormSubmit from '../components/FormSubmit';

import type {TagLookupFormT} from './types';

const TagLookupForm = ({form}: {+form: TagLookupFormT}) => (
  <div className="searchform">
    <form action="/taglookup/index" method="get">
      <FormRowTextLong
        field={form.field.artist}
        label={addColonText(l('Artist'))}
        uncontrolled
      />
      <FormRowTextLong
        field={form.field.release}
        label={addColonText(l('Release'))}
        uncontrolled
      />
      <FormRowText
        field={form.field.tracknum}
        label={addColonText(l('Track number'))}
        uncontrolled
      />
      <FormRowTextLong
        field={form.field.track}
        label={addColonText(l('Track'))}
        uncontrolled
      />
      <FormRowText
        field={form.field.duration}
        label={addColonText(l('Duration'))}
        uncontrolled
      />
      <FormRowTextLong
        field={form.field.filename}
        label={addColonText(l('Filename'))}
        uncontrolled
      />
      <FormRow hasNoLabel>
        <FormSubmit label={l('Search')} />
      </FormRow>
    </form>
  </div>
);

export default TagLookupForm;
