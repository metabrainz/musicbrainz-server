/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FieldErrors from './FieldErrors.js';
import FormRowText from './FormRowText.js';

export type ActionT = {+credit: string, +type: 'update-relationship-credit'};

export type StateT = DatePeriodFieldT;

component UrlRelationshipCreditFieldset(
  dispatch: (ActionT) => void,
  field: FieldT<string | null>,
) {
  function handleCreditChange(
    event: SyntheticInputEvent<HTMLInputElement>,
  ) {
    dispatch({
      credit: event.currentTarget.value,
      type: 'update-relationship-credit',
    });
  }

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
