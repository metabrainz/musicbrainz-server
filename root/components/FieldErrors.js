/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import subfieldErrors from '../utility/subfieldErrors';

const buildErrorListItem = (error, index) => (
  <li key={index}>{error}</li>
);

type Props<F> = {|
  +field: AnyFieldT<F>,
|};

const FieldErrors = <F>({field}: Props<F>) => {
  if (!field) {
    return null;
  }
  const errors = subfieldErrors(field);
  if (errors.length) {
    return (
      <ul className="errors">
        {errors.map(buildErrorListItem)}
      </ul>
    );
  }
  return null;
};

export default FieldErrors;
