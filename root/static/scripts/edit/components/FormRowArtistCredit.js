/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  type ActionT as ArtistCreditActionT,
  type StateT as ArtistCreditStateT,
} from './ArtistCreditEditor/types.js';
import ArtistCreditEditor from './ArtistCreditEditor.js';
import FieldErrors from './FieldErrors.js';
import FormRow from './FormRow.js';

component FormRowAreaAutocomplete(
  artistCreditField: ArtistCreditFieldT,
  dispatch: (ArtistCreditActionT) => void,
  onFocus?: (event: SyntheticEvent<HTMLInputElement>) => void,
  rowRef?: {-current: HTMLDivElement | null},
  state: ArtistCreditStateT,
) {
  return (
    <FormRow rowRef={rowRef}>
      <label className="required" htmlFor="ac-source-single-artist">
        {addColonText(l('Artist'))}
      </label>
      <ArtistCreditEditor
        dispatch={dispatch}
        onFocus={onFocus}
        state={state}
      />
      <FieldErrors field={artistCreditField} />
    </FormRow>
  );
}

export default FormRowAreaAutocomplete;
