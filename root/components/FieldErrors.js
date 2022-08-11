/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import expand2react from '../static/scripts/common/i18n/expand2react.js';
import {type AnyFieldT} from '../utility/iterSubfields.js';
import subfieldErrors from '../utility/subfieldErrors.js';

// FIXME: Use expandable object instead of HTML string for safety (MBS-10632)
const buildErrorListItem = (
  error: string,
  hasHtmlErrors: boolean = false,
  index: number,
) => {
  if (hasHtmlErrors) {
    return (
      <li key={index}>{expand2react(error)}</li>
    );
  }
  return <li key={index}>{error}</li>;
};

type Props = {
  +field: AnyFieldT,
  +hasHtmlErrors?: boolean,
  +includeSubFields?: boolean,
};

const FieldErrors = ({
  field,
  hasHtmlErrors,
  includeSubFields = true,
}: Props): React.Element<'ul'> | null => {
  if (!field) {
    return null;
  }
  const errors = includeSubFields
    ? subfieldErrors(field)
    : field.errors;
  if (errors?.length) {
    return (
      <ul className="errors">
        {errors.map(function (error, index) {
          return buildErrorListItem(error, hasHtmlErrors, index);
        })}
      </ul>
    );
  }
  return null;
};

export default FieldErrors;
