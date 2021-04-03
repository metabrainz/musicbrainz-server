/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ErrorLayout from './ErrorLayout';
import ErrorEnvironment from './components/ErrorEnvironment';
import ErrorInfo from './components/ErrorInfo';

type Props = {
  +$c: CatalystContextT,
  +formattedErrors?: $ReadOnlyArray<string>,
  +hostname?: string,
  +useLanguages: boolean,
};

const TimeoutError = ({
  $c,
  formattedErrors,
  hostname,
  useLanguages,
}: Props): React.Element<typeof ErrorLayout> => (
  <ErrorLayout title={l('Request Timed Out')}>
    <p>
      <strong>
        {l('Processing your request took too long and timed out.')}
      </strong>
    </p>

    <p>
      {l('It may help to try again by reloading the page.')}
    </p>

    <div style={{display: 'none'}}>
      <h2>{l('Technical Information')}</h2>
      <ErrorInfo formattedErrors={formattedErrors} />
      <ErrorEnvironment
        $c={$c}
        hostname={hostname}
        useLanguages={useLanguages}
      />
    </div>
  </ErrorLayout>
);

export default TimeoutError;
