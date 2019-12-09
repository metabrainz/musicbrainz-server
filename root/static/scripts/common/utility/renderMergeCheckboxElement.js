/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

export default function renderMergeCheckboxElement(
  entity: CoreEntityT,
  form: MergeFormT,
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
        checked={entity.id === form.field.target.value}
        name="merge.target"
        type="radio"
        value={entity.id}
      />
    </>
  );
}
