/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Autocomplete2 from '../../common/components/Autocomplete2.js';
import type {
  ActionT as AutocompleteActionT,
  StateT as AutocompleteStateT,
} from '../../common/components/Autocomplete2/types.js';

import FieldErrors from './FieldErrors.js';
import FormRow from './FormRow.js';

component FormRowAreaAutocomplete(
  areaField: AreaFieldT,
  dispatch: (AutocompleteActionT<AreaT>) => void,
  onFocus?: (event: SyntheticEvent<HTMLInputElement>) => void,
  rowRef?: {-current: HTMLDivElement | null},
  state: AutocompleteStateT<AreaT>,
) {
  return (
    <FormRow rowRef={rowRef}>
      <Autocomplete2
        dispatch={dispatch}
        onFocus={onFocus}
        state={state}
      />
      <FieldErrors field={areaField} />
    </FormRow>
  );
}

export default FormRowAreaAutocomplete;
