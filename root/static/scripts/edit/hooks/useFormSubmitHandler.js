/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {useCallback} from 'react';

export default function useFormSubmitHandler(
  hasErrors: boolean,
  dispatch: ({
    readonly type: 'show-all-pending-errors',
  }) => void,
): (SyntheticEvent<HTMLFormElement>) => void {
  return useCallback((event: SyntheticEvent<HTMLFormElement>) => {
    if (hasErrors) {
      dispatch({type: 'show-all-pending-errors'});
      event.preventDefault();
    }
  }, [hasErrors, dispatch]);
}
