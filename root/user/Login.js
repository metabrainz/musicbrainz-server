/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CONTACT_URL} from '../constants.js';
import {CatalystContext} from '../context.mjs';
import Layout from '../layout/index.js';
import manifest from '../static/manifest.mjs';
import PostParameters, {
  type PostParametersT,
} from '../static/scripts/common/components/PostParameters.js';
import {
  DB_STAGING_SERVER,
  DB_STAGING_SERVER_SANITIZED,
} from '../static/scripts/common/DBDefs.mjs';
import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';
import FormRowCheckbox
  from '../static/scripts/edit/components/FormRowCheckbox.js';
import FormRowText from '../static/scripts/edit/components/FormRowText.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';
import returnUri from '../utility/returnUri.js';

type LoginFormT = FormT<{
  +csrf_token: FieldT<string>,
  +password: FieldT<string>,
  +remember_me: FieldT<boolean>,
  +username: FieldT<string>,
}>;

component Login(
  isLoginBad: boolean = false,
  isLoginRequired: boolean = false,
  isSpammer: boolean = false,
  loginAction: string,
  loginForm: LoginFormT,
  postParameters: PostParametersT | null,
) {
  const $c = React.useContext(CatalystContext);
  return (
    <Layout fullWidth title={lp('Log in', 'header')}>
      <h1>{lp('Log in', 'header')}</h1>

      {isLoginRequired ? (
        <p>
          <strong>{l('You need to be logged in to view this page.')}</strong>
        </p>
      ) : null}

      <p>
        {exp.l(
          `Don't have an account? {uri|Create one now}!`,
          {uri: returnUri($c, '/register')},
        )}
      </p>

      <form action={loginAction} method="post">
        <FormCsrfToken form={loginForm} />

        {isLoginBad ? (
          <div className="row no-label">
            <span className="error">
              <strong>{l('Incorrect username or password')}</strong>
            </span>
          </div>
        ) : null}

        {isSpammer ? (
          <div className="row no-label">
            <span className="error">
              <p>
                <strong>
                  {l(`You cannot log in because this account
                      has been marked as a spam account.`)}
                </strong>
              </p>
              <p>
                {exp.l(
                  `If you think this is a mistake, please {contact|contact us}
                   with the name of your account.`,
                  {contact: CONTACT_URL},
                )}
              </p>
            </span>
          </div>
        ) : null}

        <FormRowText
          field={loginForm.field.username}
          label={addColonText(l('Username'))}
          required
          uncontrolled
        />

        <FormRowText
          field={loginForm.field.password}
          label={l('Password:')}
          required
          type="password"
          uncontrolled
        />

        {(DB_STAGING_SERVER && DB_STAGING_SERVER_SANITIZED) ? (
          <div className="row no-label">
            <span className="input-note sanitized-password-note">
              {l(`This is a development server;
                  all passwords have been reset to "mb".`)}
            </span>
          </div>
        ) : null}

        <FormRowCheckbox
          field={loginForm.field.remember_me}
          label={l('Keep me logged in')}
          uncontrolled
        />

        {postParameters ? <PostParameters params={postParameters} /> : null}

        <div className="row no-label">
          <FormSubmit className="login" label={lp('Log in', 'interactive')} />
        </div>
      </form>

      <p>
        {exp.l('Forgot your {link1|username} or {link2|password}?', {
          link1: '/lost-username',
          link2: '/lost-password',
        })}
      </p>

      {manifest('user/login', {async: 'async'})}
    </Layout>
  );
}

export default Login;
