/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {useEffect} from 'react';

const TARGET_REFS = new Map();

if (typeof document !== 'undefined') {
  document.addEventListener('mouseup', function (event: MouseEvent) {
    const eventTarget = event.target;
    if (!(eventTarget instanceof Node)) {
      return;
    }
    /*
     * N.B. It's possible for action() to cause a component to re-render that
     * then calls `useOutsideClickEffect` again, mutating `TARGET_REFS`. Thus
     * it's important that we wrap the iterator in `Array.from()`.
     */
    for (const [ref, action] of Array.from(TARGET_REFS.entries())) {
      if (action == null) {
        continue;
      }
      const target = ref.current;
      if (target && !target.contains(eventTarget)) {
        action(eventTarget);
      }
    }
  });
}

export default function useOutsideClickEffect<T: HTMLElement>(
  targetRef: {current: T | null},
  action: ((EventTarget) => void) | null,
  cleanup?: () => void,
) {
  if (typeof document === 'undefined') {
    return;
  }

  /* eslint-disable-next-line react-hooks/rules-of-hooks */
  useEffect(() => {
    TARGET_REFS.set(targetRef, action);
    return () => {
      TARGET_REFS.delete(targetRef);
      if (cleanup) {
        cleanup();
      }
    };
  }, [action, cleanup, targetRef]);
}
