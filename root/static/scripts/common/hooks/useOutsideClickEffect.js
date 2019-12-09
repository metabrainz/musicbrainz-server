/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {useEffect} from 'react';

const EMPTY_ARRAY = [];

const TARGET_REFS = new Map();

if (typeof document !== 'undefined') {
  document.addEventListener('mouseup', function (event: MouseEvent) {
    for (const [ref, action] of TARGET_REFS) {
      const target = ref.current;
      // $FlowFixMe
      if (target && !target.contains(event.target)) {
        action();
      }
    }
  });
}

export default function useOutsideClickEffect(
  targetRef: {current: HTMLElement | null},
  action: () => void,
  cleanup?: () => void,
) {
  if (typeof document === 'undefined') {
    return;
  }

  useEffect(() => {
    TARGET_REFS.set(targetRef, action);
    return () => {
      TARGET_REFS.delete(targetRef);
      if (cleanup) {
        cleanup();
      }
    };
  }, EMPTY_ARRAY);
}
