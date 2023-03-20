/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

export default function useRangeSelectionHandler(
  className: string,
): (event: MouseEvent) => void {
  const lastClicked = React.useRef<HTMLInputElement | null>(null);
  const ignoreEvents = React.useRef<boolean>(false);

  return React.useCallback(function (event: MouseEvent) {
    if (ignoreEvents.current) {
      return;
    }
    const target = event.target;
    const container = event.currentTarget;

    /*:: invariant(container instanceof HTMLElement); */

    if (
      target instanceof HTMLInputElement &&
      target.type === 'checkbox' &&
      target.classList.contains(className)
    ) {
      if (
        lastClicked.current !== null &&
        lastClicked.current !== target &&
        event.shiftKey
      ) {
        const checkboxes = container.querySelectorAll('input.' + className);
        const isTargetChecked = target.checked;
        let lastClickedIndex = -1;
        let targetIndex = -1;
        let index = -1;
        for (const checkbox of checkboxes) {
          ++index;
          /*:: invariant(checkbox instanceof HTMLInputElement); */
          if (checkbox === lastClicked.current) {
            lastClickedIndex = index;
            if (targetIndex >= 0) {
              break;
            }
          } else if (checkbox === target) {
            targetIndex = index;
            if (lastClickedIndex >= 0) {
              break;
            }
          }
        }
        invariant(
          lastClickedIndex >= 0 &&
          targetIndex >= 0 &&
          lastClickedIndex !== targetIndex,
        );
        let startIndex = -1;
        let endIndex = -1;
        if (lastClickedIndex > targetIndex) {
          startIndex = targetIndex + 1;
          endIndex = lastClickedIndex;
        } else {
          startIndex = lastClickedIndex;
          endIndex = targetIndex - 1;
        }
        for (index = startIndex; index <= endIndex; ++index) {
          const checkbox = checkboxes[index];
          /*:: invariant(checkbox instanceof HTMLInputElement); */
          if (checkbox.checked !== isTargetChecked) {
            ignoreEvents.current = true;
            checkbox.click();
            ignoreEvents.current = false;
          }
        }
      }
      lastClicked.current = target;
    }
  }, [className]);
}
