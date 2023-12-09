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

export function handleTab(
  activeElement: HTMLElement | null,
  container: HTMLElement,
  trapFocus: boolean = false,
  event: SyntheticKeyboardEvent<HTMLElement> | null,
): HTMLElement | null {
  if (activeElement && container.contains(activeElement)) {
    const shiftKey = (event?.shiftKey) === true;
    const tabbableElements = tabbable(container);
    if (!tabbableElements.length) {
      return null;
    }
    const activeElementIndex = tabbableElements.indexOf(activeElement);
    if (activeElementIndex < 0) {
      return null;
    }
    const lastTabbableElementIndex = tabbableElements.length - 1;
    let nextTabbableElement = null;
    let focusTrapped = false;
    if (shiftKey) {
      if (activeElementIndex === 0) {
        if (trapFocus) {
          nextTabbableElement = tabbableElements[lastTabbableElementIndex];
          focusTrapped = true;
        }
      } else {
        nextTabbableElement = tabbableElements[activeElementIndex - 1];
      }
    } else if (activeElementIndex === lastTabbableElementIndex) {
      if (trapFocus) {
        nextTabbableElement = tabbableElements[0];
        focusTrapped = true;
      }
    } else {
      nextTabbableElement = tabbableElements[activeElementIndex + 1];
    }
    if (focusTrapped) {
      if (event != null) {
        event.preventDefault();
      }
      invariant(
        nextTabbableElement != null,
        'nextTabbableElement is non-null if the focus was trapped',
      )
      nextTabbableElement.focus();
    }
    return nextTabbableElement;
  }
  return null;
}

export function handleTabKeyPress(
  event: SyntheticKeyboardEvent<HTMLElement>,
  container: HTMLElement,
  trapFocus?: boolean = false,
): HTMLElement | null {
  return handleTab(
    document.activeElement,
    container,
    trapFocus,
    event,
  );
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
