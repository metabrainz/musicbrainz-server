/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import setCookie from '../../common/utility/setCookie.js';

component NewNotesAlertCheckbox(checked: boolean) {
  const handlePreferenceChange = (
    event: SyntheticInputEvent<HTMLInputElement>,
  ) => {
    setCookie('alert_new_edit_notes', String(event.currentTarget.checked));
  };

  return (
    <p>
      <label>
        <input
          defaultChecked={checked}
          id="alert-new-edit-notes"
          onChange={handlePreferenceChange}
          type="checkbox"
        />
        {' '}
        {l('Show me an alert whenever I receive a new edit note.')}
      </label>
    </p>
  );
}

export default (
  hydrate<React.PropsOf<NewNotesAlertCheckbox>>(
    'span.new-notes-alert-checkbox',
    NewNotesAlertCheckbox,
  ): component(...React.PropsOf<NewNotesAlertCheckbox>)
);
