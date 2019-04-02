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

import FieldErrors from '../../../../components/FieldErrors';
import FormLabel from '../../../../components/FormLabel';
import FormRow from '../../../../components/FormRow';
import FormRowEmailLong from '../../../../components/FormRowEmailLong';
import FormRowPartialDate from '../../../../components/FormRowPartialDate';
import FormRowSelect from '../../../../components/FormRowSelect';
import FormRowTextArea from '../../../../components/FormRowTextArea';
import FormRowURLLong from '../../../../components/FormRowURLLong';
import FormSubmit from '../../../../components/FormSubmit';
import SelectField from '../../../../components/SelectField';
import DBDefs from '../../common/DBDefs-client';
import Autocomplete from '../../common/components/Autocomplete';
import Warning from '../../common/components/Warning';
import {pushCompoundField} from '../../edit/utility/pushField';
import hydrate from '../../../../utility/hydrate';

// Models just what we need from root/static/scripts/common/entity.js
type AreaClassT = {
  gid: string | null,
  id: number | null,
  name: string,
};

type FluencyT = 'basic' | 'intermediate' | 'advanced' | 'native';

type UserLanguageFieldT = CompoundFieldT<{|
  +fluency: FieldT<FluencyT | null>,
  +language_id: FieldT<number | null>,
|}>;

type EditProfileFormT = FormT<{|
  +area: AreaFieldT,
  +area_id: FieldT<number | null>,
  +biography: FieldT<string>,
  +birth_date: PartialDateFieldT,
  +email: FieldT<string>,
  +gender_id: FieldT<number>,
  +languages: RepeatableFieldT<UserLanguageFieldT>,
  +username: FieldT<string>,
  +website: FieldT<string>,
|}>;

type Props = {|
  +form: EditProfileFormT,
  +language_options: MaybeGroupedOptionsT,
|};

type State = {|
  form: EditProfileFormT,
  +languageOptions: MaybeGroupedOptionsT,
|};

const genderOptions = {
  grouped: false,
  options: [
    {label: N_l('Male'), value: 1},
    {label: N_l('Female'), value: 2},
    {label: N_l('Other'), value: 3},
  ],
};

const fluencyOptions = {
  grouped: false,
  options: [
    {label: N_l('Basic'), value: 'basic'},
    {label: N_l('Intermediate'), value: 'intermediate'},
    {label: N_l('Advanced'), value: 'advanced'},
    {label: N_l('Native'), value: 'native'},
  ],
};

class EditProfileForm extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {form: props.form, languageOptions: props.language_options};
    this.handleAreaChange = this.handleAreaChange.bind(this);
    this.handleGenderChange = this.handleGenderChange.bind(this);
    this.handleLanguageChange = this.handleLanguageChange.bind(this);
    this.handleFluencyChange = this.handleFluencyChange.bind(this);
    this.removeLanguage = this.removeLanguage.bind(this);
    this.handleLanguageAdd = this.handleLanguageAdd.bind(this);
  }

  handleAreaChange: (area: AreaClassT) => void;

  handleAreaChange(area: AreaClassT) {
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      const formField = newState.form.field;
      formField.area_id.value = area.id;
      formField.area.field.name.value = area.name;
      formField.area.field.gid.value = area.gid;
    }));
  }

  handleGenderChange: (e: SyntheticEvent<HTMLSelectElement>) => void;

  handleGenderChange(e: SyntheticEvent<HTMLSelectElement>) {
    const selectedGender = e.currentTarget.value;
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      newState.form.field.gender_id.value = parseInt(selectedGender, 10);
    }));
  }

  handleLanguageChange: (
    e: SyntheticEvent<HTMLSelectElement>,
    languageIndex: number,
  ) => void;

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

  handleFluencyChange: (
    e: SyntheticEvent<HTMLSelectElement>,
    languageIndex: number,
  ) => void;

  handleFluencyChange(
    e: SyntheticEvent<HTMLSelectElement>,
    languageIndex: number,
  ) {
    // $FlowFixMe ~ string incompatible with FluencyT's string literals
    const selectedFluency: FluencyT = e.currentTarget.value;
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      const compound = newState.form.field.languages.field[languageIndex];
      compound.field.fluency.value = selectedFluency;
    }));
  }

  removeLanguage: (languageIndex: number) => void;

  removeLanguage(languageIndex: number) {
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      newState.form.field.languages.field.splice(languageIndex, 1);
    }));
  }

  handleLanguageAdd: () => void;

  handleLanguageAdd() {
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      pushCompoundField(newState.form.field.languages, {
        fluency: null,
        language_id: null,
      });
    }));
  }

  render() {
    const field = this.state.form.field;
    const areaField = field.area.field;
    return (
      <form id="edit-profile-form" method="post">
        <input
          hidden
          id={'id-' + field.username.html_name}
          name={field.username.html_name}
          readOnly
          value={field.username.value}
        />
        {DBDefs.DB_STAGING_TESTING_FEATURES ? (
          <Warning
            message={l('This is a development server. Your email address is not private or secure. Proceed with caution!')}
          />
        ) : null}

        <FormRowEmailLong
          field={field.email}
          label={addColonText(l('Email'))}
        />
        <FormRow hasNoLabel>
          {l('If you change your email address, you will be required to verify it.')}
        </FormRow>

        <FormRowURLLong
          field={field.website}
          label={addColonText(l('Website'))}
        />

        <FormRowSelect
          allowEmpty
          field={field.gender_id}
          label={l('Gender:')}
          onChange={this.handleGenderChange}
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
            onChange={this.handleAreaChange}
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
          {l('You can pick the level you prefer here: your country, region or city. Be as specific as you want to!')}
        </FormRow>

        <FormRowPartialDate
          field={field.birth_date}
          label={l('Birth date:')}
        />
        <FormRow hasNoLabel>
          {l('We will use your birth date to display your age in years on your profile page.')}
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
                  allowEmpty={false}
                  field={languageField.field.language_id}
                  onChange={(e) => this.handleLanguageChange(e, index)}
                  options={this.state.languageOptions}
                />
                <SelectField
                  allowEmpty={false}
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
              </li>
            ))}
            <li key="add">
              <span className="buttons">
                <button
                  className="another"
                  onClick={this.handleLanguageAdd}
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
export default hydrate<Props>('edit-profile-form', EditProfileForm);
