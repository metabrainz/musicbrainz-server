/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {CONTACT_URL} from '../constants.js';
import Layout from '../layout/index.js';
import * as manifest from '../static/manifest.mjs';
import RegisterForm, {type RegisterFormT}
  from '../static/scripts/account/components/RegisterForm.js';
import Warning from '../static/scripts/common/components/Warning.js';

type Props = {
  +captcha: string,
  +form: RegisterFormT,
  +invalidCaptchaResponse: boolean,
};

const Register = ({
  captcha,
  form,
  invalidCaptchaResponse,
}: Props): React$Element<typeof Layout> => (
  <Layout fullWidth title={l('Create an Account')}>
    {invalidCaptchaResponse ? (
      <Warning
        message={l('Captcha incorrect. Try again.')}
      />
    ) : null}

    <h1>{l('Create an Account')}</h1>

    <p>
      {exp.l(
        `<strong>Note that any contributions you make to MusicBrainz
         will be released into the Public Domain and/or licensed under
         a Creative Commons by-nc-sa license. Furthermore, you give
         the MetaBrainz Foundation the right to license this data
         for commercial use. Please read our {doc|license page}
         for more details.</strong>`,
        {doc: '/doc/About/Data_License'},
      )}
    </p>

    <p>
      {exp.l(
        `MusicBrainz believes strongly in the privacy of its users!
         Any personal information you choose to provide will not be sold
         or shared with anyone else. For full details,
         please read our {doc|Privacy Policy}.`,
        {doc: 'https://metabrainz.org/privacy'},
      )}
    </p>

    <p>
      {exp.l(
        `You may remove your personal information from our services anytime
         by deleting your account. For more details,
         see our {doc|GDPR compliance statement}.`,
        {doc: 'https://metabrainz.org/gdpr'},
      )}
    </p>

    <RegisterForm captcha={captcha} form={form} />
    {manifest.js('account/components/RegisterForm', {async: 'async'})}

    <p>
      {exp.l(
        `If you have any questions, please review the {faq|FAQs}
         or {doc|documentation} before {con|contacting us}. `,
        {
          con: CONTACT_URL,
          doc: '/doc/MusicBrainz_Documentation',
          faq: '/doc/Frequently_Asked_Questions',
        },
      )}
    </p>

    <p>
      {exp.l(
        `Follow our {bl|blog} or {tw|twitter account}!
         To talk to other users, try the {fo|forums} or {irc|IRC}.`,
        {
          bl: 'http://blog.metabrainz.org/',
          fo: 'https://community.metabrainz.org/',
          irc: '/doc/Communication/IRC',
          tw: 'https://twitter.com/MusicBrainz',
        },
      )}
    </p>

    <p>
      {l(
        `MusicBrainz has one account type for all users.
         If you represent an artist or label,
         please use the above form to create an account.`,
      )}
    </p>
  </Layout>
);

export default Register;
