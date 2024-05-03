/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FieldErrors from '../static/scripts/edit/components/FieldErrors.js';
import FormLabel from '../static/scripts/edit/components/FormLabel.js';
import FormRow from '../static/scripts/edit/components/FormRow.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

import type {OtherLookupFormT} from './types.js';

component OtherLookupFormRow(
  action: string,
  field: FieldT<string>,
  label: string,
) {
  return (
    <form action={'/otherlookup/' + action}>
      <FormRow>
        <FormLabel
          forField={field}
          label={label}
          required={field.has_errors}
        />
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
}

component OtherLookupForm(form: OtherLookupFormT) {
  return (
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
}

export default OtherLookupForm;
