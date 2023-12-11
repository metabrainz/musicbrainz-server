/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {flushSync} from 'react-dom';
import {tabbable} from 'tabbable';

export function findFirstTabbableElement(
  container: HTMLElement,
  skipAnchors?: ?boolean,
): HTMLElement | null {
  const nodes = tabbable(container);
  if (skipAnchors === true) {
    return (nodes.find(node => node.nodeName !== 'A')) ?? null;
  }
  return nodes.length ? nodes[0] : null;
}

export function performReactUpdateAndMaintainFocus(
  elementIdToFocus: string,
  callback: () => void,
): void {
  let elementToFocus = document.getElementById(elementIdToFocus);

  const parents: Array<HTMLElement> = [];
  let current: ?Element = elementToFocus;
  while (current) {
    const parent = current.parentElement;
    if (parent && parent instanceof HTMLElement) {
      parents.push(parent);
    }
    current = parent;
  }

  flushSync(callback);

  // The element may have moved outside of its existing tree.  Find it.
  elementToFocus = document.getElementById(elementIdToFocus);

  if (elementToFocus) {
    if (elementToFocus !== document.activeElement) {
      elementToFocus.focus();
    }
    return;
  }

  // If it no longer exists, return focus to the closest tabbable element.
  for (const parent of parents) {
    if (parent.isConnected) {
      const tabbableElement = findFirstTabbableElement(
        parent,
        false,
      );
      if (tabbableElement) {
        tabbableElement.focus();
        break;
      }
    }
  }
}
