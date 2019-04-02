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

import FormRow from '../../../../components/FormRow';
import FormRowSelect from '../../../../components/FormRowSelect';
import FormRowText from '../../../../components/FormRowText';
import FormRowURLLong from '../../../../components/FormRowURLLong';
import FormSubmit from '../../../../components/FormSubmit';
import hydrate from '../../../../utility/hydrate';

export type OauthTypeT = 'installed' | 'web';

export type ApplicationFormT = FormT<{|
  +name: ReadOnlyFieldT<string>,
  +oauth_redirect_uri: FieldT<string>,
  +oauth_type: FieldT<OauthTypeT>,
|}>;

type Props = {|
  +action: string,
  +form: ApplicationFormT,
  +submitLabel: string,
|};

type State = {|
  form: ApplicationFormT,
|};

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
    this.handleOauthRedirectURIChange = this.handleOauthRedirectURIChange.bind(this);
    this.handleOauthTypeChange = this.handleOauthTypeChange.bind(this);
  }

  handleOauthRedirectURIChange: (e: SyntheticEvent<HTMLInputElement>) => void;

  handleOauthRedirectURIChange(e: SyntheticEvent<HTMLInputElement>) {
    const selectedOauthRedirectURI = e.currentTarget.value;
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      newState.form.field.oauth_redirect_uri.value = selectedOauthRedirectURI;
    }));
  }

  handleOauthTypeChange: (e: SyntheticEvent<HTMLSelectElement>) => void;

  handleOauthTypeChange(e: SyntheticEvent<HTMLSelectElement>) {
    const selectedOauthType = e.currentTarget.value;
    this.setState(prevState => mutate<State, _>(prevState, newState => {
      newState.form.field.oauth_type.value = ((selectedOauthType: any): OauthTypeT);
    }));
  }

  render() {
    return (
      <form method="post">
        <FormRowText
          field={this.state.form.field.name}
          label={addColonText(l('Name'))}
          required
        />
        <FormRowSelect
          field={this.state.form.field.oauth_type}
          frozen={this.props.action === 'edit'}
          label={addColonText(l('Type'))}
          onChange={this.handleOauthTypeChange}
          options={oauthTypeOptions}
          required
        />
        <FormRowURLLong
          field={this.state.form.field.oauth_redirect_uri}
          label={addColonText(l('Callback URL'))}
          onChange={this.handleOauthRedirectURIChange}
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
export default hydrate<Props>('application-form', ApplicationForm);
