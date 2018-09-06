/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import noop from 'lodash/noop';

import FormRow from '../../components/FormRow';
import FormRowSelect from '../../components/FormRowSelect';
import FormRowText from '../../components/FormRowText';
import FormRowURLLong from '../../components/FormRowURLLong';
import FormSubmit from '../../components/FormSubmit';
import {addColon, l, N_l} from '../../static/scripts/common/i18n';
import {Lens, prop, set, compose3} from '../../static/scripts/common/utility/lens';
import hydrate from '../../utility/hydrate';

import type {OauthTypeT, ApplicationFormT} from './types';

type Props = {|
  +form: ApplicationFormT,
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

const oauthRedirectURIFieldLens: Lens<ApplicationFormT, string> =
  compose3(prop('field'), prop('oauth_redirect_uri'), prop('value'));

const oauthTypeFieldLens: Lens<ApplicationFormT, OauthTypeT> =
  compose3(prop('field'), prop('oauth_type'), prop('value'));

class RegisterApplicationForm extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {form: props.form};
    this.handleOauthRedirectURIChange = this.handleOauthRedirectURIChange.bind(this);
    this.handleOauthTypeChange = this.handleOauthTypeChange.bind(this);
  }

  handleOauthRedirectURIChange: (e: SyntheticEvent<HTMLInputElement>) => void;

  handleOauthRedirectURIChange(e: SyntheticEvent<HTMLInputElement>) {
    const currentOauthRedirectURI = e.currentTarget.value;
    this.setState(prevState => ({
      form: set(
        oauthRedirectURIFieldLens,
        (currentOauthRedirectURI: any),
        prevState.form,
      ),
    }));
  }

  handleOauthTypeChange: (e: SyntheticEvent<HTMLSelectElement>) => void;

  handleOauthTypeChange(e: SyntheticEvent<HTMLSelectElement>) {
    const currentOauthType = e.currentTarget.value;
    this.setState(prevState => ({
      form: set(
        oauthTypeFieldLens,
        (currentOauthType: any),
        prevState.form,
      ),
    }));
  }

  render() {
    return (
      <form action="/account/applications/register" method="post">
        <FormRowText
          field={this.state.form.field.name}
          label={addColon(l('Name'))}
          required
        />
        <FormRowSelect
          field={this.state.form.field.oauth_type}
          label={addColon(l('Type'))}
          onChange={this.handleOauthTypeChange}
          options={oauthTypeOptions}
        />
        {this.state.form.field.oauth_type.value === 'web' ? (
          <FormRowURLLong
            field={this.state.form.field.oauth_redirect_uri}
            label={addColon(l('Callback URL'))}
            onChange={this.handleOauthRedirectURIChange}
          />
        ) : null}
        <FormRow hasNoLabel>
          <FormSubmit label={l('Register')} />
        </FormRow>
      </form>
    );
  }
}

export type RegisterApplicationFormPropsT = Props;
export default hydrate<Props>('register-application-form', RegisterApplicationForm);
