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
import ErrorEnvironment from './components/ErrorEnvironment';
import ErrorInfo from './components/ErrorInfo';

type Props = {
  +$c: CatalystContextT,
  +message?: string,
  +useLanguages: boolean,
};

const Error400 = ({
  $c,
  message,
  useLanguages,
}: Props): React.Element<typeof ErrorLayout> => (
  <ErrorLayout $c={$c} title={l('Bad Request')}>
    <p>
      <strong>
        {l('Sorry, there was a problem with your request.')}
      </strong>
    </p>

    <ErrorInfo message={message} />

    <p>
      {exp.l(
        'Looking for help? Check out our {doc|documentation} or {faq|FAQ}.',
        {doc: '/doc/MusicBrainz_Documentation', faq: '/doc/FAQ'},
      )}
    </p>

    <p>
      {exp.l(
        `Found a problem on our site? Please {report|report a bug}
         and include any error message that is shown above.`,
        {
          report: bugTrackerURL(),
        },
      )}
    </p>

    <h2>{l('Technical Information')}</h2>

    <ErrorEnvironment $c={$c} useLanguages={useLanguages} />
  </ErrorLayout>
);

export default Error400;
