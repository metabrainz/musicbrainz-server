/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FieldErrors from '../../edit/components/FieldErrors.js';
import FormRowText from '../../edit/components/FormRowText.js';

export type ActionT = {+credit: string, +type: 'update-relationship-credit'};

export type StateT = DatePeriodFieldT;

component UrlRelationshipCreditFieldset(
  dispatch: (ActionT) => void,
  field: FieldT<string | null>,
) {
  const handleCreditChange = React.useCallback((
    event: SyntheticInputEvent<HTMLInputElement>,
  ) => {
    dispatch({
      credit: event.currentTarget.value,
      type: 'update-relationship-credit',
    });
  }, [dispatch]);

  return (
    <fieldset>
      <legend>{l('Credit')}</legend>
      <FormRowText
        field={field}
        label={addColonText(l('Credited to'))}
        onChange={handleCreditChange}
      />
      <FieldErrors
        field={field}
        includeSubFields={false}
      />
    </fieldset>
  );
}

export default UrlRelationshipCreditFieldset;
