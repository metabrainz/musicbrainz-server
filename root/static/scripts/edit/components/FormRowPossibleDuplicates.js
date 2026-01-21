/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FormRow from './FormRow.js';
import PossibleDuplicates from './PossibleDuplicates.js';

component FormRowPossibleDuplicates(
  duplicates: $ReadOnlyArray<EditableEntityT>,
  name: string,
  onCheckboxChange: (event: SyntheticEvent<HTMLInputElement>) => void,
  rowRef?: {-current: HTMLDivElement | null},
) {
  if (!duplicates.length) {
    return null;
  }

  return (
    <FormRow hasNoLabel rowRef={rowRef}>
      <PossibleDuplicates
        duplicates={duplicates}
        name={name}
        onCheckboxChange={onCheckboxChange}
      />
    </FormRow>
  );
}
export default FormRowPossibleDuplicates;
