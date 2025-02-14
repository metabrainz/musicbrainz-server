/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

component ListMergeButtonsRow(
  label: string,
) {
  const handleClick = () => {
    const checkboxes = document.querySelectorAll(
      '.mergeable-table input[type=checkbox]',
    );

    // Push unset to happen after form submit so checkboxes do count
    setTimeout(() => {
      for (const checkbox of checkboxes) {
        /*:: invariant(checkbox instanceof HTMLInputElement); */
        checkbox.checked = false;
      }
    }, 0);
  };

  return (
    <div className="row">
        <span className="buttons">
        <button onClick={handleClick} type="submit">
            {label}
        </button>
        <button formTarget="_blank" onClick={handleClick} type="submit">
            {exp.l('{action_label} (in a new tab)', {action_label: label})}
        </button>
        </span>
    </div>
  );
}

export default (hydrate<React.PropsOf<ListMergeButtonsRow>>(
  'div.list-merge-buttons-row-container',
  ListMergeButtonsRow,
): React.AbstractComponent<React.PropsOf<ListMergeButtonsRow>>);
