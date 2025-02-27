/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import newTabIconUrl from '../../../images/icons/new_tab.svg';

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

  const newTabLabel = exp.l(
    '{action_label} (in a new tab)',
    {action_label: label},
  );

  return (
    <div className="row">
      <span className="buttons">
        <button onClick={handleClick} type="submit">
            {label}
        </button>
        <button
          aria-label={newTabLabel}
          formTarget="_blank"
          onClick={handleClick}
          title={newTabLabel}
          type="submit"
        >
          <img
            alt={newTabLabel}
            src={newTabIconUrl}
          />
        </button>
      </span>
    </div>
  );
}

export default (hydrate<React.PropsOf<ListMergeButtonsRow>>(
  'div.list-merge-buttons-row-container',
  ListMergeButtonsRow,
): React.AbstractComponent<React.PropsOf<ListMergeButtonsRow>>);
