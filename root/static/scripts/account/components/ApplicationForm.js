/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';

import FormCsrfToken from '../../edit/components/FormCsrfToken.js';
import FormRow from '../../edit/components/FormRow.js';
import FormRowSelect from '../../edit/components/FormRowSelect.js';
import FormRowText from '../../edit/components/FormRowText.js';
import FormRowURLLong from '../../edit/components/FormRowURLLong.js';
import FormSubmit from '../../edit/components/FormSubmit.js';

export type ApplicationFormT = FormT<{
  +csrf_token: FieldT<string>,
  +name: FieldT<string>,
  +oauth_redirect_uri: FieldT<string>,
  +oauth_type: FieldT<string>,
}>;

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {+type: 'set-oauth-redirect-uri', +oauthRedirectURI: string}
  | {+type: 'set-oauth-type', +oauthType: string};
/* eslint-enable ft-flow/sort-keys */

type StateT = {
  +form: ApplicationFormT,
};

const oauthTypeOptions = {
  grouped: false,
  options: [
    {label: N_l('Web application'), value: 'web'},
    {label: N_l('Installed application'), value: 'installed'},
  ],
};

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);
  switch (action.type) {
    case 'set-oauth-redirect-uri': {
      newStateCtx.set(
        'form',
        'field',
        'oauth_redirect_uri',
        'value',
        action.oauthRedirectURI,
      );
      break;
    }
    case 'set-oauth-type': {
      newStateCtx
        .set('form', 'field', 'oauth_type', 'value', action.oauthType);
      break;
    }
    default: {
      /*:: exhaustive(action); */
    }
  }
  return newStateCtx.final();
}

component ApplicationForm(
  action: string,
  form as initialForm: ApplicationFormT,
  submitLabel: string,
) {
  const [state, dispatch] = React.useReducer(
    reducer,
    {form: initialForm},
  );

  const handleOauthRedirectURIChange = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    const selectedOauthRedirectURI = event.currentTarget.value;
    dispatch({
      oauthRedirectURI: selectedOauthRedirectURI,
      type: 'set-oauth-redirect-uri',
    });
  }, [dispatch]);

  const handleOauthTypeChange = React.useCallback((
    event: SyntheticEvent<HTMLSelectElement>,
  ) => {
    const selectedOauthType = event.currentTarget.value;
    dispatch({oauthType: selectedOauthType, type: 'set-oauth-type'});
  }, [dispatch]);

  return (
    <form method="post">
      <FormCsrfToken form={state.form} />

      <FormRowText
        field={state.form.field.name}
        label={addColonText(l('Name'))}
        required
        uncontrolled
      />
      <FormRowSelect
        field={state.form.field.oauth_type}
        frozen={action === 'edit'}
        label={addColonText(l('Type'))}
        onChange={handleOauthTypeChange}
        options={oauthTypeOptions}
        required
      />
      <FormRowURLLong
        field={state.form.field.oauth_redirect_uri}
        label={addColonText(l('Callback URI'))}
        onChange={handleOauthRedirectURIChange}
        required={state.form.field.oauth_type.value === 'web'}
      />
      {state.form.field.oauth_type.value === 'web' ? null : (
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
        <FormSubmit label={submitLabel} />
      </FormRow>
    </form>
  );
}

export default (hydrate<React.PropsOf<ApplicationForm>>(
  'div.application-form',
  ApplicationForm,
): component(...React.PropsOf<ApplicationForm>));
