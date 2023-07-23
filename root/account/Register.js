/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {CONTACT_URL} from '../constants.js';
import Layout from '../layout/index.js';
import manifest from '../static/manifest.mjs';
import RegisterForm, {type RegisterFormT}
  from '../static/scripts/account/components/RegisterForm.js';
import Warning from '../static/scripts/common/components/Warning.js';

component Register(
  form: RegisterFormT,
  invalidCaptchaResponse: boolean,
) {
  return (
    <Layout fullWidth title={lp('Create an account', 'header')}>
      {invalidCaptchaResponse ? (
        <Warning
          message={l('Captcha incorrect. Try again.')}
        />
      ) : null}

      <h1>{lp('Create an account', 'header')}</h1>

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

      <RegisterForm form={form} />
      {manifest('account/components/RegisterForm', {async: true})}

      <p>
        {exp.l(
          `If you have any questions, please review the {faq|FAQs}
           or {doc|documentation} before {con|contacting us}.`,
          {
            con: CONTACT_URL,
            doc: '/doc/MusicBrainz_Documentation',
            faq: '/doc/Frequently_Asked_Questions',
          },
        )}
      </p>

      <p>
        {exp.l(
          `Follow our {blog_link|blog} or our {bluesky_link|Bluesky}
           or {mastodon_link|Mastodon} accounts! To talk to other users,
           try the {forum_link|forums} or the {chat_link|chat}.`,
          {
            blog_link: 'http://blog.metabrainz.org/',
            bluesky_link: 'https://bsky.app/profile/musicbrainz.org',
            chat_link: '/doc/Communication/ChatBrainz',
            forum_link: 'https://community.metabrainz.org/',
            mastodon_link: 'https://mastodon.social/@MusicBrainz',
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
}

export default Register;
