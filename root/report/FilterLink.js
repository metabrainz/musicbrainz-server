/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import uriWith from '../utility/uriWith';
import {withCatalystContext} from '../context';

const FilterLink = (
  {$c, filtered}: {$c: CatalystContextT, filtered: boolean},
) => {
  const reqUri = $c.req.uri;

  return (
    <li>
      {filtered === true ? (
        <a href={uriWith(reqUri, {filter: 0})}>
          {l('Show all results.')}
        </a>
      ) : (
        <a href={uriWith(reqUri, {filter: 1})}>
          {l('Show only results that are in my subscribed entities.')}
        </a>
      )}
    </li>
  );
};

export default withCatalystContext(FilterLink);
