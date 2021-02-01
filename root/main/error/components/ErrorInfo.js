/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

type Props = {
  +formattedErrors?: $ReadOnlyArray<string>,
  +message?: string,
};

const ErrorInfo = ({
  formattedErrors,
  message,
}: Props): (React.Element<'p'>) => (
  formattedErrors ? (
    <p id="errors">
      <strong>{ln('Error:', 'Errors:', formattedErrors.length)}</strong>
      {formattedErrors.map((error, index) => <pre key={index}>{error}</pre>)}
    </p>
  ) : (
    <p>
      <strong>{l('Error message: ')}</strong>
      {nonEmpty(message) ? (
        <code>{message}</code>
      ) : (
        <code>{l('(No details about this error are available)')}</code>
      )}
    </p>
  )
);

export default ErrorInfo;
