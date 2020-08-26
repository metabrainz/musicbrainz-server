/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../context';

const FormCsrfToken = ():
React.Element<typeof SanitizedCatalystContext.Consumer> => (
  <SanitizedCatalystContext.Consumer>
    {$c => (
      <>
        {$c.stash.invalid_csrf_token /*:: === true */ ? (
          <p className="error">
            {l(`The form you’ve submitted has expired.
                Please resubmit your request.`)}
          </p>
        ) : null}
        <input
          name="csrf_token"
          type="hidden"
          value={$c.stash.csrf_token ?? ''}
        />
      </>
    )}
  </SanitizedCatalystContext.Consumer>
);

export default FormCsrfToken;
