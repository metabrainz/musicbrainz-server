// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import React from 'react';
import {l} from '../static/scripts/common/i18n';
import Layout from '../layout';

// Please try and keep the WikiDoc templates (doc/error.tt & doc/bare_error.tt)
// looking similar to how this template looks.

const _404 = (props) => (
  <Layout {...props} title={l('Page Not Found')} fullWidth={true}>
    <div id="content">
      <h1>{l('Page Not Found')}</h1>
      <p>
        <strong>{l('Sorry, the page you\'re looking for does not exist.')}</strong>
      </p>
      {props.message &&
        <p>
          <strong>{l('Error message: ')}</strong>
          <code>{props.message}</code>
        </p>}
      <p>
        {l('Looking for help? Check out our {doc|documentation} or {faq|FAQ}.',
           {__react: true, doc: '/doc/MusicBrainz_Documentation', faq: doc_link('FAQ')})}
      </p>
      <p>
        {l('Found a broken link on our site? Please {report|report a bug} and include any error message that is shown above.',
           {__react: true,
            report: 'http://tickets.musicbrainz.org/secure/CreateIssue.jspa?pid=10000&issuetype=1&description=Broken+link:' +
                    encodeURIComponent($c.req.url) +
                    '+Referer:' +
                    encodeURIComponent($c.req.headers.referer)})}
      </p>
    </div>
  </Layout>
);

export default _404;
