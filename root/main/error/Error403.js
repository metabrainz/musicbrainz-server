/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import bugTrackerURL from '../../static/scripts/common/utility/bugTrackerURL';

import ErrorLayout from './ErrorLayout';

type Props = {
  +$c: CatalystContextT,
};

const Error403 = ({
  $c,
}: Props): React.Element<typeof ErrorLayout> => (
  <ErrorLayout title={l('Forbidden Request')}>
    <p>
      <strong>
        {l('The page you requested is private.')}
      </strong>
    </p>
    <p>
      {exp.l(
        'Looking for help? Check out our {doc|documentation} or {faq|FAQ}.',
        {doc: '/doc/MusicBrainz_Documentation', faq: '/doc/FAQ'},
      )}
    </p>
    <p>
      {exp.l(
        `If you followed a link on our site to get here,
         please {report|report a bug} and the URL
         of the page that sent you here.`,
        {
          report: bugTrackerURL(
            'Forbidden page: ' + $c.req.uri + '\n' +
            'Referrer: ' + ($c.req.headers.referer || ''),
          ),
        },
      )}
    </p>
  </ErrorLayout>
);

export default Error403;
