/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FieldErrors from '../components/FieldErrors.js';
import FormLabel from '../components/FormLabel.js';
import FormRow from '../components/FormRow.js';
import FormSubmit from '../components/FormSubmit.js';

import type {OtherLookupFormT} from './types.js';

type OtherLookupFormProps = {
  +form: OtherLookupFormT,
};

type OtherLookupFormRowProps = {
  +action: string,
  +field: ReadOnlyFieldT<string>,
  +label: string,
};

const OtherLookupFormRow = ({
  action,
  field,
  label,
}: OtherLookupFormRowProps): React.Element<'form'> => (
  <form action={'/otherlookup/' + action}>
    <FormRow>
      <FormLabel forField={field} label={label} required={field.has_errors} />
      <input
        className={field.has_errors ? 'error' : ''}
        defaultValue={field.value ?? ''}
        id={'id-' + field.html_name}
        name={field.html_name}
        required={field.has_errors}
        size="32"
        type="text"
      />
      <FormSubmit className="inline" label={l('Search')} />
      <FieldErrors field={field} />
    </FormRow>
  </form>
);

const OtherLookupForm = ({
  form,
}: OtherLookupFormProps): React.Element<'div'> => (
  <div className="searchform">
    <OtherLookupFormRow
      action="catno"
      field={form.field.catno}
      label={addColonText(l('Catalog number'))}
    />
    <OtherLookupFormRow
      action="barcode"
      field={form.field.barcode}
      label={addColonText(l('Barcode'))}
    />
    <OtherLookupFormRow
      action="url"
      field={form.field.url}
      label={addColonText(l('URL'))}
    />
    <OtherLookupFormRow
      action="isrc"
      field={form.field.isrc}
      label={addColonText(l('ISRC'))}
    />
    <OtherLookupFormRow
      action="iswc"
      field={form.field.iswc}
      label={addColonText(l('ISWC'))}
    />
    <OtherLookupFormRow
      action="artist-ipi"
      field={form.field['artist-ipi']}
      label={l('Artist IPI:')}
    />
    <OtherLookupFormRow
      action="artist-isni"
      field={form.field['artist-isni']}
      label={l('Artist ISNI:')}
    />
    <OtherLookupFormRow
      action="label-ipi"
      field={form.field['label-ipi']}
      label={l('Label IPI:')}
    />
    <OtherLookupFormRow
      action="label-isni"
      field={form.field['label-isni']}
      label={l('Label ISNI:')}
    />
    <OtherLookupFormRow
      action="freedbid"
      field={form.field.freedbid}
      label={l('FreeDB ID:')}
    />
    <OtherLookupFormRow
      action="mbid"
      field={form.field.mbid}
      label={addColonText(l('MBID'))}
    />
    <OtherLookupFormRow
      action="discid"
      field={form.field.discid}
      label={addColonText(l('Disc ID'))}
    />
  </div>
);

export default OtherLookupForm;
