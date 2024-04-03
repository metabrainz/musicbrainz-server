/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context.mjs';

component ErrorEnvironment(hostname?: string, useLanguages: boolean = false) {
  const $c = React.useContext(CatalystContext);
  return (
    <>
      <p>
        <strong>{addColonText(l('Date and time'))}</strong>
        {' '}
        {new Date().toISOString()}
      </p>

      {nonEmpty(hostname) ? (
        <p>
          <strong>{l('Host:')}</strong>
          {' '}
          {hostname}
        </p>
      ) : null}

      {useLanguages ? (
        <p>
          <strong>{l('Interface language:')}</strong>
          {' '}
          {$c.stash.current_language}
        </p>
      ) : null}

      <p>
        <strong>{addColonText(l('URL'))}</strong>
        {' '}
        <code>{$c.req.uri}</code>
      </p>

      <p>
        <strong>{l('Request data:')}</strong>
        <pre>
          {JSON.stringify({
            body_parameters: $c.req.body_params,
            query_parameters: $c.req.query_params,
          }, null, 2)}
        </pre>
      </p>

    </>
  );
}

export default ErrorEnvironment;
