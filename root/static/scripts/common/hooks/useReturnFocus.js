/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

export default function useReturnFocus<T: HTMLElement>(
  target: {current: T | null},
): {current: boolean} {
  const shouldReturnFocus = React.useRef(false);

  React.useEffect(() => {
    if (shouldReturnFocus.current) {
      if (target.current) {
        target.current.focus();
      }
      shouldReturnFocus.current = false;
    }
  });

  return shouldReturnFocus;
}
