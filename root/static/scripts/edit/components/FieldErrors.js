/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import expand2react from '../../common/i18n/expand2react.js';
import subfieldErrors from '../utility/subfieldErrors.js';

// FIXME: Use expandable object instead of HTML string for safety (MBS-10632)
const buildErrorListItem = (
  error: string,
  hasHtmlErrors: boolean,
  index: number,
) => {
  if (hasHtmlErrors) {
    return (
      <li key={index}>{expand2react(error)}</li>
    );
  }
  return <li key={index}>{error}</li>;
};

export component FieldErrorsList(
  errors: ?$ReadOnlyArray<string>,
  hasHtmlErrors: boolean,
) {
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
}

component FieldErrors(
  field: AnyFieldT,
  hasHtmlErrors: boolean = false,
  includeSubFields: boolean = true,
 ) {
  if (!field) {
    return null;
  }
  const errors = includeSubFields
    ? subfieldErrors(field)
    : field.errors;
  return (
    <FieldErrorsList
      errors={errors}
      hasHtmlErrors={hasHtmlErrors}
    />
  );
}

export default FieldErrors;
