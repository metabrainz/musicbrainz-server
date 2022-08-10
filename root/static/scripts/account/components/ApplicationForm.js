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

import FormCsrfToken from '../../../../components/FormCsrfToken';
import FormRow from '../../../../components/FormRow';
import FormRowSelect from '../../../../components/FormRowSelect';
import FormRowText from '../../../../components/FormRowText';
import FormRowURLLong from '../../../../components/FormRowURLLong';
import FormSubmit from '../../../../components/FormSubmit';

export type ApplicationFormT = FormT<{
  +csrf_token: FieldT<string>,
  +name: ReadOnlyFieldT<string>,
  +oauth_redirect_uri: FieldT<string>,
  +oauth_type: FieldT<string>,
}>;

type Props = {
  +action: string,
  +form: ApplicationFormT,
  +submitLabel: string,
};

type State = {
  form: ApplicationFormT,
};

const oauthTypeOptions = {
  grouped: false,
  options: [
    {label: N_l('Web Application'), value: 'web'},
    {label: N_l('Installed Application'), value: 'installed'},
  ],
};

class ApplicationForm extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {form: props.form};
    this.handleOauthRedirectURIChangeBound =
      (e) => this.handleOauthRedirectURIChange(e);
    this.handleOauthTypeChangeBound =
      (e) => this.handleOauthTypeChange(e);
  }

  handleOauthRedirectURIChangeBound:
    (e: SyntheticEvent<HTMLInputElement>) => void;

  handleOauthRedirectURIChange(e: SyntheticEvent<HTMLInputElement>) {
    const selectedOauthRedirectURI = e.currentTarget.value;
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      newState.form.field.oauth_redirect_uri.value = selectedOauthRedirectURI;
    }));
  }

  handleOauthTypeChangeBound: (e: SyntheticEvent<HTMLSelectElement>) => void;

  handleOauthTypeChange(e: SyntheticEvent<HTMLSelectElement>) {
    const selectedOauthType = e.currentTarget.value;
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      newState.form.field.oauth_type.value = selectedOauthType;
    }));
  }

  render(): React.Element<'form'> {
    return (
      <form method="post">
        <FormCsrfToken form={this.state.form} />

        <FormRowText
          field={this.state.form.field.name}
          label={addColonText(l('Name'))}
          required
          uncontrolled
        />
        <FormRowSelect
          field={this.state.form.field.oauth_type}
          frozen={this.props.action === 'edit'}
          label={addColonText(l('Type'))}
          onChange={this.handleOauthTypeChangeBound}
          options={oauthTypeOptions}
          required
        />
        <FormRowURLLong
          field={this.state.form.field.oauth_redirect_uri}
          label={addColonText(l('Callback URL'))}
          onChange={this.handleOauthRedirectURIChangeBound}
          required={this.state.form.field.oauth_type.value === 'web'}
        />
        {this.state.form.field.oauth_type.value === 'web' ? null : (
          <FormRow hasNoLabel>
            <span className="input-note">
              {exp.l(
                `Callback URI is optional for installed applications.
                 If set, its scheme must be a custom reverse-DNS string,
                 as in <code>org.example.app://auth</code>,
                 for installed applications.`,
              )}
            </span>
          </FormRow>
        )}
        <FormRow hasNoLabel>
          <FormSubmit label={this.props.submitLabel} />
        </FormRow>
      </form>
    );
  }
}

export type ApplicationFormPropsT = Props;
export default (hydrate<Props>(
  'div.application-form',
  ApplicationForm,
): React.AbstractComponent<Props, void>);
