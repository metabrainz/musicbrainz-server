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
import DBDefs from '../../common/DBDefs-client.mjs';
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
  id: number | null,
  name: string,
};

type UserLanguageFieldT = CompoundFieldT<{
  +fluency: FieldT<FluencyT | null>,
  +language_id: FieldT<number | null>,
}>;

type EditProfileFormT = FormT<{
  +area: AreaFieldT,
  +area_id: FieldT<number | null>,
  +biography: FieldT<string>,
  +birth_date: PartialDateFieldT,
  +csrf_token: FieldT<string>,
  +email: FieldT<string>,
  +gender_id: FieldT<number>,
  +languages: RepeatableFieldT<UserLanguageFieldT>,
  +username: FieldT<string>,
  +website: FieldT<string>,
}>;

type Props = {
  +form: EditProfileFormT,
  +language_options: MaybeGroupedOptionsT,
};

type State = {
  form: EditProfileFormT,
  +languageOptions: MaybeGroupedOptionsT,
};

const genderOptions = {
  grouped: false,
  options: [
    {label: N_lp_attributes('Male', 'gender'), value: 1},
    {label: N_lp_attributes('Female', 'gender'), value: 2},
    {label: N_lp_attributes('Non-binary', 'gender'), value: 5},
    {label: N_lp_attributes('Other', 'gender'), value: 3},
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

class EditProfileForm extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {form: props.form, languageOptions: props.language_options};
    this.handleAreaChangeBound = (area) => this.handleAreaChange(area);
    this.handleGenderChangeBound = (e) => this.handleGenderChange(e);
    this.handleLanguageAddBound = () => this.handleLanguageAdd();
  }

  handleAreaChangeBound: (area: AreaClassT) => void;

  handleAreaChange(area: AreaClassT) {
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      const formField = newState.form.field;
      formField.area_id.value = area.id;
      formField.area.field.name.value = area.name;
      formField.area.field.gid.value = area.gid;
    }));
  }

  handleGenderChangeBound: (e: SyntheticEvent<HTMLSelectElement>) => void;

  handleGenderChange(e: SyntheticEvent<HTMLSelectElement>) {
    const selectedGender = e.currentTarget.value;
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      newState.form.field.gender_id.value = parseInt(selectedGender, 10);
    }));
  }

  handleLanguageChange(
    e: SyntheticEvent<HTMLSelectElement>,
    languageIndex: number,
  ) {
    const selectedLanguage = parseInt(e.currentTarget.value, 10);
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      const compound = newState.form.field.languages.field[languageIndex];
      compound.field.language_id.value = selectedLanguage;
    }));
  }

  handleFluencyChange(
    e: SyntheticEvent<HTMLSelectElement>,
    languageIndex: number,
  ) {
    const selectedValue = e.currentTarget.value;
    let selectedFluency: FluencyT | null = null;
    switch (selectedValue) {
      case 'basic':
      case 'intermediate':
      case 'advanced':
      case 'native':
        selectedFluency = selectedValue;
    }
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      const compound = newState.form.field.languages.field[languageIndex];
      compound.field.fluency.value = selectedFluency;
    }));
  }

  removeLanguage(languageIndex: number) {
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      newState.form.field.languages.field.splice(languageIndex, 1);
    }));
  }

  handleLanguageAddBound: () => void;

  handleLanguageAdd() {
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      pushCompoundField(newState.form.field.languages, {
        fluency: null,
        language_id: null,
      });
    }));
  }

  render(): React.Element<'form'> {
    const form = this.state.form;
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
        {DBDefs.DB_STAGING_TESTING_FEATURES ? (
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
          label={l('Gender:')}
          onChange={this.handleGenderChangeBound}
          options={genderOptions}
        />

        <FormRow>
          <FormLabel
            forField={areaField.name}
            label={l('Location:')}
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
            onChange={this.handleAreaChangeBound}
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
          label={l('Bio:')}
        />

        <FormRow>
          <FormLabel label={l('Languages Known:')} />
          <ul className="inline">
            {field.languages.field.map((languageField, index) => (
              <li className="language" key={index}>
                <SelectField
                  allowEmpty
                  field={languageField.field.language_id}
                  onChange={(e) => this.handleLanguageChange(e, index)}
                  options={this.state.languageOptions}
                />
                <SelectField
                  allowEmpty
                  field={languageField.field.fluency}
                  onChange={(e) => this.handleFluencyChange(e, index)}
                  options={fluencyOptions}
                />
                <span className="buttons inline">
                  <button
                    className="remove negative"
                    onClick={() => (this.removeLanguage(index))}
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
                  onClick={this.handleLanguageAddBound}
                  type="button"
                >
                  {l('Add a language')}
                </button>
              </span>
            </li>
          </ul>
        </FormRow>

        <FormRow hasNoLabel>
          <FormSubmit label={l('Save')} />
        </FormRow>
      </form>
    );
  }
}

export type EditProfileFormPropsT = Props;

export default (
  hydrate<Props>('div.edit-profile-form', EditProfileForm):
  React.AbstractComponent<Props, void>
);
