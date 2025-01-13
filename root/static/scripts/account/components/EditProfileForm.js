/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';

import Autocomplete from '../../common/components/Autocomplete.js';
import SelectField from '../../common/components/SelectField.js';
import Warning from '../../common/components/Warning.js';
import {FLUENCY_NAMES} from '../../common/constants.js';
import {DB_STAGING_TESTING_FEATURES} from '../../common/DBDefs-client.mjs';
import {N_lp_attributes} from '../../common/i18n/attributes.js';
import FieldErrors from '../../edit/components/FieldErrors.js';
import FormCsrfToken from '../../edit/components/FormCsrfToken.js';
import FormLabel from '../../edit/components/FormLabel.js';
import FormRow from '../../edit/components/FormRow.js';
import FormRowEmailLong from '../../edit/components/FormRowEmailLong.js';
import FormRowPartialDate from '../../edit/components/FormRowPartialDate.js';
import FormRowSelect from '../../edit/components/FormRowSelect.js';
import FormRowTextArea from '../../edit/components/FormRowTextArea.js';
import FormRowURLLong from '../../edit/components/FormRowURLLong.js';
import FormSubmit from '../../edit/components/FormSubmit.js';
import {pushCompoundField} from '../../edit/utility/pushField.js';

// Models just what we need from root/static/scripts/common/entity.js
type AreaClassT = {
  gid: string | null,
  id: string | null,
  name: string,
};

type UserLanguageFieldT = CompoundFieldT<{
  +fluency: FieldT<FluencyT | null>,
  +language_id: FieldT<string | null>,
}>;

type EditProfileFormT = FormT<{
  +area: AreaFieldT,
  +area_id: FieldT<string | null>,
  +biography: FieldT<string>,
  +birth_date: PartialDateFieldT,
  +csrf_token: FieldT<string>,
  +email: FieldT<string>,
  +gender_id: FieldT<string>,
  +languages: RepeatableFieldT<UserLanguageFieldT>,
  +username: FieldT<string>,
  +website: FieldT<string>,
}>;

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {+type: 'add-language'}
  | {+type: 'remove-language', +index: number}
  | {+type: 'set-area', +area: AreaClassT};
/* eslint-enable ft-flow/sort-keys */

type StateT = {
  +form: EditProfileFormT,
};

const genderOptions = {
  grouped: false,
  options: [
    {label: N_lp_attributes('Male', 'gender'), value: '1'},
    {label: N_lp_attributes('Female', 'gender'), value: '2'},
    {label: N_lp_attributes('Non-binary', 'gender'), value: '5'},
    {label: N_lp_attributes('Other', 'gender'), value: '3'},
  ],
};

const fluencyOptions = {
  grouped: false,
  options: [
    {label: FLUENCY_NAMES.basic, value: 'basic'},
    {label: FLUENCY_NAMES.intermediate, value: 'intermediate'},
    {label: FLUENCY_NAMES.advanced, value: 'advanced'},
    {label: FLUENCY_NAMES.native, value: 'native'},
  ],
};

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);
  switch (action.type) {
    case 'add-language': {
      pushCompoundField<{
        fluency: FluencyT | null,
        language_id: string | null,
      }>(newStateCtx.get('form', 'field', 'languages'), {
        fluency: null,
        language_id: null,
      });
      break;
    }
    case 'remove-language': {
      newStateCtx
        .get('form', 'field', 'languages', 'field')
        .write()
        .splice(action.index, 1);
      break;
    }
    case 'set-area': {
      newStateCtx
        .get('form', 'field')
        .set('area_id', 'value', action.area.id)
        .get('area', 'field')
        .set('name', 'value', action.area.name)
        .set('gid', 'value', action.area.gid);
      break;
    }
    default: {
      /*:: exhaustive(action); */
    }
  }
  return newStateCtx.final();
}

component EditProfileForm(
  form as initialForm: EditProfileFormT,
  language_options: MaybeGroupedOptionsT,
) {
  const [state, dispatch] = React.useReducer(
    reducer,
    {form: initialForm},
  );

  const handleAreaChange = React.useCallback((
    area: AreaClassT,
  ) => {
    dispatch({area, type: 'set-area'});
  }, [dispatch]);

  const removeLanguage = React.useCallback((
    languageIndex: number,
  ) => {
    dispatch({index: languageIndex, type: 'remove-language'});
  }, [dispatch]);

  const handleLanguageAdd = React.useCallback(() => {
    dispatch({type: 'add-language'});
  }, [dispatch]);

  const form = state.form;
  const field = form.field;
  const areaField = field.area.field;
  return (
    <form id="edit-profile-form" method="post">
      <FormCsrfToken form={form} />

      <input
        hidden
        id={'id-' + field.username.html_name}
        name={field.username.html_name}
        readOnly
        value={field.username.value}
      />
      {DB_STAGING_TESTING_FEATURES ? (
        <Warning
          message={l(
            `This is a development server. Your email address is not private
             or secure. Proceed with caution!`,
          )}
        />
      ) : null}

      <FormRowEmailLong
        field={field.email}
        label={addColonText(l('Email'))}
        uncontrolled
      />
      <FormRow hasNoLabel>
        {l(
          `If you change your email address,
           you will be required to verify it.`,
        )}
      </FormRow>

      <FormRowURLLong
        field={field.website}
        label={addColonText(l('Website'))}
        uncontrolled
      />

      <FormRowSelect
        allowEmpty
        field={field.gender_id}
        label={addColonText(l('Gender'))}
        options={genderOptions}
        uncontrolled
      />

      <FormRow>
        <FormLabel
          forField={areaField.name}
          label={addColonText(lp('Location', 'user area'))}
        />
        <Autocomplete
          currentSelection={{
            gid: areaField.gid.value,
            id: field.area_id.value,
            name: areaField.name.value,
          }}
          entity="area"
          inputID={'id-' + areaField.name.html_name}
          inputName={areaField.name.html_name}
          onChange={handleAreaChange}
        >
          <input
            name={field.area_id.html_name}
            type="hidden"
            value={field.area_id.value || ''}
          />
        </Autocomplete>
        <FieldErrors field={areaField.gid} />
        <FieldErrors field={field.area_id} />
        <FieldErrors field={areaField.name} />
      </FormRow>
      <FormRow hasNoLabel>
        {l(
          `You can pick the level you prefer here: your country,
           region or city. Be as specific as you want to!`,
        )}
      </FormRow>

      <FormRowPartialDate
        field={field.birth_date}
        label={l('Birth date:')}
        uncontrolled
      />
      <FormRow hasNoLabel>
        {l(
          `We will use your birth date to display your age
           in years on your profile page.`,
        )}
      </FormRow>

      <FormRowTextArea
        field={field.biography}
        label={addColonText(l('Bio'))}
        uncontrolled
      />

      <FormRow>
        <FormLabel label={l('Languages known:')} />
        <ul className="inline">
          {field.languages.field.map((languageField, index) => (
            <li className="language" key={index}>
              <SelectField
                allowEmpty
                field={languageField.field.language_id}
                options={language_options}
                uncontrolled
              />
              <SelectField
                allowEmpty
                field={languageField.field.fluency}
                options={fluencyOptions}
                uncontrolled
              />
              <span className="buttons inline">
                <button
                  className="remove negative"
                  onClick={() => (removeLanguage(index))}
                  type="button"
                >
                  {l('Remove')}
                </button>
              </span>
              <FieldErrors field={languageField.field.language_id} />
              <FieldErrors field={languageField.field.fluency} />
            </li>
          ))}
          <li key="add">
            <span className="buttons">
              <button
                className="another"
                onClick={handleLanguageAdd}
                type="button"
              >
                {lp('Add language', 'interactive')}
              </button>
            </span>
          </li>
        </ul>
      </FormRow>

      <FormRow hasNoLabel>
        <FormSubmit label={lp('Save', 'interactive')} />
      </FormRow>
    </form>
  );
}

export default (hydrate<React.PropsOf<EditProfileForm>>(
  'div.edit-profile-form',
  EditProfileForm,
): component(...React.PropsOf<EditProfileForm>));
