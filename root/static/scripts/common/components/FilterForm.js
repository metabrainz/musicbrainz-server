/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FieldErrors from '../../edit/components/FieldErrors.js';

import SelectField from './SelectField.js';

type GenericFilterFormFieldsT = {
  readonly disambiguation: FieldT<string>,
  readonly name: FieldT<string>,
};

type EventFilterFormT = FormT<{
  ...GenericFilterFormFieldsT,
  readonly setlist: FieldT<string>,
  readonly type_id: FieldT<number>,
}>;

export type EventFilterT = Readonly<{
  ...EventFilterFormT,
  readonly entity_type: 'event',
  readonly options_type_id: SelectOptionsT,
}>;

type RecordingFilterFormT = FormT<{
  ...GenericFilterFormFieldsT,
  readonly artist_credit_id: FieldT<number>,
  readonly hide_bootlegs: FieldT<boolean>,
  readonly video: FieldT<number>,
  readonly works: FieldT<number>,
}>;

export type RecordingFilterT = Readonly<{
  ...RecordingFilterFormT,
  readonly entity_type: 'recording',
  readonly options_artist_credit_id: SelectOptionsT,
  readonly options_video: SelectOptionsT,
  readonly options_works: SelectOptionsT,
}>;

type ReleaseFilterFormT = FormT<{
  ...GenericFilterFormFieldsT,
  readonly artist_credit_id: FieldT<number>,
  readonly country_id: FieldT<number>,
  readonly date: FieldT<string>,
  readonly label_id: FieldT<number>,
  readonly status_id: FieldT<number>,
}>;

export type ReleaseFilterT = Readonly<{
  ...ReleaseFilterFormT,
  readonly entity_type: 'release',
  readonly options_artist_credit_id: SelectOptionsT,
  readonly options_country_id: SelectOptionsT,
  readonly options_label_id: SelectOptionsT,
  readonly options_status_id: SelectOptionsT,
}>;

type ReleaseGroupFilterFormT = FormT<{
  ...GenericFilterFormFieldsT,
  readonly artist_credit_id: FieldT<number>,
  readonly secondary_type_id: FieldT<number>,
  readonly type_id: FieldT<number>,
}>;

export type ReleaseGroupFilterT = Readonly<{
  ...ReleaseGroupFilterFormT,
  readonly entity_type: 'release_group',
  readonly options_artist_credit_id: SelectOptionsT,
  readonly options_secondary_type_id: SelectOptionsT,
  readonly options_type_id: SelectOptionsT,
}>;

type WorkFilterFormT = FormT<{
  ...GenericFilterFormFieldsT,
  readonly language_id: FieldT<number>,
  readonly role_type: FieldT<number>,
  readonly type_id: FieldT<number>,
}>;

export type WorkFilterT = Readonly<{
  ...WorkFilterFormT,
  readonly entity_type: 'work',
  readonly options_language_id: SelectOptionsT,
  readonly options_role_type: SelectOptionsT,
  readonly options_type_id: SelectOptionsT,
}>;

export type FilterFormT =
  | EventFilterT
  | RecordingFilterT
  | ReleaseFilterT
  | ReleaseGroupFilterT
  | WorkFilterT;

function getSubmitText(form: FilterFormT) {
  return match (form.entity_type) {
    'event' => l('Filter events'),
    'recording' => l('Filter recordings'),
    'release' => l('Filter releases'),
    'release_group' => l('Filter release groups'),
    'work' => l('Filter works'),
  };
}

component ArtistCreditField(
  field: FieldT<number>,
  options: SelectOptionsT,
) {
  return (
    <tr>
      <td>
        {addColonText(l('Artist credit'))}
      </td>
      <td>
        <SelectField
          field={field}
          options={{
            grouped: false,
            options,
          }}
          style={{maxWidth: '40em'}}
          uncontrolled
        />
      </td>
    </tr>
  );
}

component TypeField(
  field: FieldT<number>,
  options: SelectOptionsT,
) {
  return (
    <tr>
      <td>
        {addColonText(l('Type'))}
      </td>
      <td>
        <SelectField
          field={field}
          options={{
            grouped: false,
            options,
          }}
          style={{maxWidth: '40em'}}
          uncontrolled
        />
      </td>
    </tr>
  );
}

component FilterForm(
  form: FilterFormT,
  showAllReleaseGroups: boolean = false,
  showVAReleaseGroups: boolean = false,
) {
  return (
    <div id="filter">
      <form method="get">
        <table>
          <tbody>
            <tr>
              <td>{addColonText(l('Name'))}</td>
              <td>
                <input
                  defaultValue={form.field.name.value}
                  name={form.field.name.html_name}
                  size={47}
                  type="text"
                />
              </td>
            </tr>

            {form.entity_type === 'event' ? (
              <>
                <TypeField
                  field={form.field.type_id}
                  options={form.options_type_id}
                />
                <tr>
                  <td>
                    {addColonText(l('Setlist contains'))}
                  </td>
                  <td>
                    <input
                      defaultValue={form.field.setlist.value ?? ''}
                      name={form.field.setlist.html_name}
                      size={47}
                      type="text"
                    />
                    <FieldErrors field={form.field.setlist} />
                  </td>
                </tr>
              </>
            ) : null}

            {form.entity_type === 'recording' ? (
              <>
                <ArtistCreditField
                  field={form.field.artist_credit_id}
                  options={form.options_artist_credit_id}
                />
                <tr>
                  <td>
                    {addColonText(l('Video'))}
                  </td>
                  <td>
                    <SelectField
                      field={form.field.video}
                      options={{
                        grouped: false,
                        options: form.options_video,
                      }}
                      style={{maxWidth: '40em'}}
                      uncontrolled
                    />
                  </td>
                </tr>
                <tr>
                  <td>
                    {addColonText(l('Works'))}
                  </td>
                  <td>
                    <SelectField
                      field={form.field.works}
                      options={{
                        grouped: false,
                        options: form.options_works,
                      }}
                      style={{maxWidth: '40em'}}
                      uncontrolled
                    />
                  </td>
                </tr>
                <tr>
                  <td
                    title={l(`Hide recordings that only appear
                              on bootleg releases`)}
                  >
                    {addColonText(l('Hide bootleg-only'))}
                  </td>
                  <td>
                    <input
                      defaultChecked={form.field.hide_bootlegs.value}
                      id={'id-' + String(form.field.hide_bootlegs.html_name)}
                      name={form.field.hide_bootlegs.html_name}
                      type="checkbox"
                      value="1"
                    />
                  </td>
                </tr>
              </>
            ) : null}

            {form.entity_type === 'release' ? (
              <>
                <ArtistCreditField
                  field={form.field.artist_credit_id}
                  options={form.options_artist_credit_id}
                />
                <tr>
                  <td>
                    {addColonText(l('Label'))}
                  </td>
                  <td>
                    <SelectField
                      field={form.field.label_id}
                      options={{
                        grouped: false,
                        options: form.options_label_id,
                      }}
                      style={{maxWidth: '40em'}}
                      uncontrolled
                    />
                  </td>
                </tr>
                <tr>
                  <td>
                    {addColonText(l('Country'))}
                  </td>
                  <td>
                    <SelectField
                      field={form.field.country_id}
                      options={{
                        grouped: false,
                        options: form.options_country_id,
                      }}
                      style={{maxWidth: '40em'}}
                      uncontrolled
                    />
                  </td>
                </tr>
                <tr>
                  <td>
                    {addColonText(lp('Status', 'release'))}
                  </td>
                  <td>
                    <SelectField
                      field={form.field.status_id}
                      options={{
                        grouped: false,
                        options: form.options_status_id,
                      }}
                      style={{maxWidth: '40em'}}
                      uncontrolled
                    />
                  </td>
                </tr>
                <tr>
                  <td>
                    {addColonText(l('Date'))}
                  </td>
                  <td>
                    <input
                      defaultValue={form.field.date.value ?? ''}
                      name={form.field.date.html_name}
                      size={47}
                      type="text"
                    />
                    <FieldErrors field={form.field.date} />
                  </td>
                </tr>
              </>
            ) : null}

            {form.entity_type === 'release_group' ? (
              <>
                <TypeField
                  field={form.field.type_id}
                  options={form.options_type_id}
                />
                <ArtistCreditField
                  field={form.field.artist_credit_id}
                  options={form.options_artist_credit_id}
                />
                <tr>
                  <td>
                    {addColonText(l('Secondary type'))}
                  </td>
                  <td>
                    <SelectField
                      field={form.field.secondary_type_id}
                      options={{
                        grouped: false,
                        options: form.options_secondary_type_id,
                      }}
                      style={{maxWidth: '40em'}}
                      uncontrolled
                    />
                  </td>
                </tr>
              </>
            ) : null}

            {form.entity_type === 'work' ? (
              <>
                <TypeField
                  field={form.field.type_id}
                  options={form.options_type_id}
                />
                <tr>
                  <td>
                    {addColonText(l('Language'))}
                  </td>
                  <td>
                    <SelectField
                      field={form.field.language_id}
                      options={{
                        grouped: false,
                        options: form.options_language_id,
                      }}
                      style={{maxWidth: '40em'}}
                      uncontrolled
                    />
                  </td>
                </tr>
                <tr>
                  <td>
                    {addColonText(l('Role'))}
                  </td>
                  <td>
                    <SelectField
                      field={form.field.role_type}
                      options={{
                        grouped: false,
                        options: form.options_role_type,
                      }}
                      style={{maxWidth: '40em'}}
                      uncontrolled
                    />
                  </td>
                </tr>
              </>
            ) : null}

            <tr>
              <td>{addColonText(l('Disambiguation'))}</td>
              <td>
                <input
                  defaultValue={form.field.disambiguation.value}
                  name={form.field.disambiguation.html_name}
                  size={47}
                  type="text"
                />
              </td>
            </tr>

            {showAllReleaseGroups
              ? <input name="all" type="hidden" value="1" />
              : null}

            {showVAReleaseGroups
              ? <input name="va" type="hidden" value="1" />
              : null}

            <tr>
              <td />
              <td>
                <span className="buttons">
                  <button className="submit positive" type="submit">
                    {getSubmitText(form)}
                  </button>
                  <button
                    className="submit negative"
                    name="filter.cancel"
                    type="submit"
                    value="1"
                  >
                    {l('Cancel')}
                  </button>
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </form>
    </div>
  );
}

export default FilterForm;
