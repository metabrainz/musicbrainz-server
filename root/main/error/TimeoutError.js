/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ErrorEnvironment from './components/ErrorEnvironment.js';
import ErrorInfo from './components/ErrorInfo.js';
import ErrorLayout from './ErrorLayout.js';

component TimeoutError(
  formattedErrors?: $ReadOnlyArray<string>,
  hostname?: string,
  useLanguages: boolean,
) {
  return (
    <ErrorLayout title={l('Request timed out')}>
      <p>
        <strong>
          {l('Processing your request took too long and timed out.')}
        </strong>
      </p>

      <p>
        {l('It may help to try again by reloading the page.')}
      </p>

      <div style={{display: 'none'}}>
        <h2>{l('Technical information')}</h2>
        <ErrorInfo formattedErrors={formattedErrors} />
        <ErrorEnvironment
          hostname={hostname}
          useLanguages={useLanguages}
        />
      </div>
    </ErrorLayout>
  );
}

export default TimeoutError;
