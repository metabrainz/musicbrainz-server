// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import React from 'react';

import {withCatalystContext} from '../context';
import Layout from '../layout';
import {l} from '../static/scripts/common/i18n';
import bugTrackerURL from '../static/scripts/common/utility/bugTrackerURL';

// Please try and keep the WikiDoc templates (doc/error.tt & doc/bare_error.tt)
// looking similar to how this template looks.

const _404 = ({$c, ...props}) => (
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
           {doc: '/doc/MusicBrainz_Documentation', faq: '/doc/FAQ'})}
      </p>
      <p>
        {l('Found a broken link on our site? Please {report|report a bug} and include any error message that is shown above.', {
          report: bugTrackerURL(
            'Nonexistent page: ' + $c.req.uri + '\n' +
            'Referrer: ' + ($c.req.headers.referer || '')
          )
        })}
      </p>
    </div>
  </Layout>
);

export default withCatalystContext(_404);
