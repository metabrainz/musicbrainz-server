/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import expand2react from '../static/scripts/common/i18n/expand2react';
import subfieldErrors, {type FieldShape} from '../utility/subfieldErrors';

// FIXME: Use expandable object instead of HTML string for safety (MBS-10632)
const buildErrorListItem = (error, hasHtmlErrors = false, index) => {
  if (hasHtmlErrors) {
    return (
      <li key={index}>{expand2react(error)}</li>
    );
  }
  return <li key={index}>{error}</li>;
};

type Props = {
  +field: FieldShape,
  +hasHtmlErrors?: boolean,
};

const FieldErrors = ({
  field,
  hasHtmlErrors,
}: Props): React.Element<'ul'> | null => {
  if (!field) {
    return null;
  }
  const errors = subfieldErrors(field);
  if (errors.length) {
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
