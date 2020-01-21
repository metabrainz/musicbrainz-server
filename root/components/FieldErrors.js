/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import expand2react from '../static/scripts/common/i18n/expand2react';
import subfieldErrors, {type FieldShape} from '../utility/subfieldErrors';

const buildErrorListItem = (error, hasHtmlErrors, index) => {
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

const FieldErrors = ({field, hasHtmlErrors}: Props) => {
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
