/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {useEffect} from 'react';

type ActionFnT = ((Event) => void) | null;

type TargetRefsT = Map<{+current: HTMLElement | null}, ActionFnT>;

// Actions by event type name.
const EVENTS = new Map<string, TargetRefsT>();

function setupEventHandler(eventType) {
  const cachedTargetActions = EVENTS.get(eventType);
  if (cachedTargetActions) {
    return cachedTargetActions;
  }

  const targetActions = new Map();
  EVENTS.set(eventType, targetActions);

  document.addEventListener((
    eventType
  ), (event: FocusEvent | KeyboardEvent | MouseEvent) => {
    const eventTarget = event.target;
    if (!(eventTarget instanceof Node)) {
      return;
    }
    /*
     * N.B. It's possible for action() to cause a component to re-render that
     * then calls `useOutsideClickEffect` again, mutating `TARGET_REFS`. Thus
     * it's important that we wrap the iterator in `Array.from()`.
     */
    for (const [ref, action] of Array.from(targetActions.entries())) {
      if (action == null) {
        continue;
      }
      /*
       * Similar to the note above, action() can also potentially remove the
       * event target from the page.
       */
      if (!document.contains(eventTarget)) {
        break;
      }
      const target = ref.current;
      if (target && !target.contains(eventTarget)) {
        action(event);
      }
    }
  });

  return targetActions;
}

export default function useEventTrap<T: HTMLElement>(
  eventType: FocusEventTypes | KeyboardEventTypes | MouseEventTypes,
  targetRef: {current: T | null},
  action: ActionFnT,
  cleanup?: () => void,
) {
  if (typeof document === 'undefined') {
    return;
  }

  const targetActions = setupEventHandler(eventType);

  /* eslint-disable-next-line react-hooks/rules-of-hooks */
  useEffect(() => {
    targetActions.set(targetRef, action);
    return () => {
      targetActions.delete(targetRef);
      if (cleanup) {
        cleanup();
      }
    };
  }, [action, cleanup, targetActions, targetRef]);
}
