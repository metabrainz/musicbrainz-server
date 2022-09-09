/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function renderMergeCheckboxElement(
  entity: CoreEntityT,
  form: MergeFormT | MergeReleasesFormT,
  index: number,
): React$MixedElement {
  return (
    <>
      <input
        name={'merge.merging.' + index}
        type="hidden"
        value={entity.id}
      />
      <input
        defaultChecked={
          String(entity.id) === String(form.field.target.value)
        }
        name="merge.target"
        type="radio"
        value={entity.id}
      />
    </>
  );
}
