/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

export default function useDialogEnterKeyHandler(
  acceptDialog: () => void,
): (event: SyntheticKeyboardEvent<HTMLElement>) => void {
  return React.useCallback((event) => {
    if (
      event.keyCode === 13 &&
      !event.isDefaultPrevented() &&
      /*
       * MBS-12619: Hitting <Enter> on a button should click the button
       * rather than accept the dialog.
       */
      !(event.target instanceof HTMLButtonElement)
    ) {
      // Prevent a click event on the ButtonPopover.
      event.preventDefault();
      // This will return focus to the button.
      acceptDialog();
    }
  }, [acceptDialog]);
}
