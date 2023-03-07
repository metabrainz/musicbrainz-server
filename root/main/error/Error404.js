/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import bugTrackerURL
  from '../../static/scripts/common/utility/bugTrackerURL.js';

import ErrorLayout from './ErrorLayout.js';

/*
 * Please try and keep the WikiDoc error template (doc/DocError.js)
 * looking similar to how this template looks.
 */

type Props = {
  +message?: string,
};

const Error404 = ({
  message,
}: Props): React$Element<typeof ErrorLayout> => {
  const $c = React.useContext(CatalystContext);
  return (
    <ErrorLayout title={l('Page Not Found')}>
      <p>
        <strong>
          {l(`Sorry, the page you're looking for does not exist.`)}
        </strong>
      </p>
      {nonEmpty(message) ? (
        <p>
          <strong>{l('Error message: ')}</strong>
          <code>{message}</code>
        </p>
      ) : null}
      <p>
        {exp.l(
          'Looking for help? Check out our {doc|documentation} or {faq|FAQ}.',
          {doc: '/doc/MusicBrainz_Documentation', faq: '/doc/FAQ'},
        )}
      </p>
      <p>
        {exp.l(
          `Found a broken link on our site? Please {report|report a bug}
            and include any error message that is shown above.`,
          {
            report: bugTrackerURL(
              'Nonexistent page: ' + $c.req.uri + '\n' +
              'Referrer: ' + ($c.req.headers.referer || ''),
            ),
          },
        )}
      </p>
    </ErrorLayout>
  );
};

export default Error404;
