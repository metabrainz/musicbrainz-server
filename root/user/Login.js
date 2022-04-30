/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FormCsrfToken from '../components/FormCsrfToken';
import FormRowCheckbox from '../components/FormRowCheckbox';
import FormRowText from '../components/FormRowText';
import FormSubmit from '../components/FormSubmit';
import PostParameters, {
  type PostParametersT,
} from '../static/scripts/common/components/PostParameters';
import Layout from '../layout';
import * as manifest from '../static/manifest';
import DBDefs from '../static/scripts/common/DBDefs';
import returnUri from '../utility/returnUri';
import octobrainzLogo from '../static/images/meb-logos/octobrainz.png';

type PropsT = {
  +$c: CatalystContextT,
  +isLoginBad?: boolean,
  +isLoginRequired?: boolean,
  +isSpammer?: boolean,
  +loginAction: string,
  +loginForm: ReadOnlyFormT<{
    +csrf_token: ReadOnlyFieldT<string>,
    +password: ReadOnlyFieldT<string>,
    +remember_me: ReadOnlyFieldT<boolean>,
    +username: ReadOnlyFieldT<string>,
  }>,
  +postParameters: PostParametersT | null,
};

const Login = ({
  $c,
  isLoginBad = false,
  isLoginRequired = false,
  isSpammer = false,
  loginAction,
  loginForm,
  postParameters,
}: PropsT): React$Element<typeof Layout> => (
  <Layout fullWidth title={l('Log In')}>
    {isLoginRequired ? (
      <p>
        <strong>{l('You need to be logged in to view this page.')}</strong>
      </p>
    ) : null}

    <div className="bs container">
      <div className="login row justify-content-center">
        <div className="col-md-6 m-4">
          <div className="card align-items-center">
            <img
              alt="OctoBrainz"
              className="card-img-top image-cover"
              height={200}
              src={octobrainzLogo}
            />
            <div className="card-body">
              <div className="card-title text-center fs-4">
                Login to Your Account
              </div>
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
                          {l(
                            `You cannot log in because this account
                                    has been marked as a spam account.`,
                          )}
                        </strong>
                      </p>
                      <p>
                        {exp.l(
                          `If you think this is a mistake, please contact
                            <code>support@musicbrainz.org</code>
                            with the name of your account.`,
                        )}
                      </p>
                    </span>
                  </div>
                ) : null}

                <span
                  className="input-group-text box-bg"
                  id="inputGroupPrepend"
                >
                  @
                </span>
                <FormRowText
                  field={loginForm.field.username}
                  label={l('Username:')}
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

                {(
                  DBDefs.DB_STAGING_SERVER &&
                      DBDefs.DB_STAGING_SERVER_SANITIZED
                ) ? (
                  <div className="row no-label">
                    <span className="input-note sanitized-password-note">
                      {l(
                        `This is a development server;
                                all passwords have been reset to "mb".`,
                      )}
                    </span>
                  </div>
                  ) : null}

                <div className="col-6">
                  <p className="small mb-0">
                    {
                      exp.l(
                        'Forgot your {link1|username} or {link2|password}?',
                        {
                          link1: '/lost-username',
                          link2: '/lost-password',
                        },
                      )}
                  </p>
                </div>

                <div className="col-6">
                  <FormRowCheckbox
                    field={loginForm.field.remember_me}
                    label={l('Keep me logged in')}
                    uncontrolled
                  />
                </div>

                {postParameters
                  ? <PostParameters params={postParameters} />
                  : null
                }

                <FormSubmit label={l('Log In')} />
              </form>
            </div>
          </div>

          <button
            className="col-12 btn btn-primary btn-lg mb-4"
            type="button"
          >
            {exp.l(
              `{uri|Create account}`,
              {uri: returnUri($c, '/register')},
            )}
          </button>
        </div>
      </div>
    </div>

    {manifest.js('user/login', {async: 'async'})}
  </Layout>
);

export default Login;
