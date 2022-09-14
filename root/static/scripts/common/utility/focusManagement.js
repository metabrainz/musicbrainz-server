/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// $FlowIgnore[missing-export]
import {flushSync} from 'react-dom';

function isElementVisible(element: HTMLElement) {
  let currentElement: ?(Element | HTMLElement) = element;
  while (currentElement) {
    const style = currentElement instanceof HTMLElement
      ? currentElement.style
      : null;
    if (style && (
      style.visibility === 'hidden' ||
      style.display === 'none'
    )) {
      return false;
    }
    currentElement = currentElement.parentElement;
  }
  return true;
}

/*
 * The default behavior on Windows/Linux, in most cases, is that the tab
 * key navigates to and focuses on links. Not so on macOS, unless
 * "Use keyboard navigation to move focus between controls" is enabled
 * under System Preferences -> Keyboard.
 */
let IS_ANCHOR_TABBABLE = true;

export function isElementTabbable(
  element: HTMLElement,
  skipAnchors?: ?boolean,
): boolean {
  if (!isElementVisible(element)) {
    return false;
  }
  switch (element.nodeName) {
    case 'A':
      if (!IS_ANCHOR_TABBABLE || (skipAnchors ?? false)) {
        return false;
      }
      // $FlowIssue[prop-missing]
      return element.href !== '' || element.tabIndex >= 0;
    case 'BUTTON':
    case 'INPUT':
    case 'SELECT':
    case 'TEXTAREA':
      // $FlowIssue[prop-missing]
      return !element.disabled;
    default:
      return element.tabIndex >= 0;
  }
}

export function detectIfAnchorIsTabbable(
  focusEvent: SyntheticKeyboardEvent<HTMLElement>,
  expectedElement: ?HTMLElement,
): void {
  if (expectedElement && expectedElement.nodeName === 'A') {
    IS_ANCHOR_TABBABLE =
      (expectedElement === focusEvent.target);
  }
}

export function getNextElement(
  containerElement: HTMLElement,
  currentElement: Element | null,
): Element | null {
  if (!currentElement) {
    return null;
  }
  switch (currentElement.nodeName) {
    case 'SELECT':
      break;
    default: {
      const children = currentElement.children;
      if (children.length) {
        return children[0];
      }
    }
  }
  let nextElement = currentElement.nextElementSibling;
  if (nextElement) {
    return nextElement;
  }
  let parent = currentElement.parentElement;
  while (parent && parent !== containerElement) {
    nextElement = parent.nextElementSibling;
    if (nextElement) {
      break;
    }
    parent = parent.parentElement;
  }
  return nextElement ?? null;
}

function findLastElementDepthFirst(
  element: Element,
): Element {
  switch (element.nodeName) {
    case 'SELECT':
      return element;
    default: {
      let lastElement = element;
      let children = lastElement.children;
      while (children.length) {
        lastElement = children[children.length - 1];
        children = lastElement.children;
      }
      return lastElement;
    }
  }
}

export function getPreviousElement(
  containerElement: HTMLElement,
  currentElement: Element | null,
): Element | null {
  if (!currentElement) {
    return null;
  }
  const previousElement = currentElement.previousElementSibling;
  if (previousElement) {
    return findLastElementDepthFirst(previousElement);
  }
  const parentElement = currentElement.parentElement;
  if (parentElement && parentElement !== containerElement) {
    return parentElement;
  }
  return null;
}

export function findTabbableElement(
  containerElement: HTMLElement,
  startingElement: Element | null,
  elementGetter: (HTMLElement, Element | null) => Element | null,
  includeStartingElement?: boolean = false,
  skipAnchors?: ?boolean,
): HTMLElement | null {
  if (startingElement === containerElement) {
    return null;
  }
  /*
   * We do not respect the tabIndex order here.
   * Do not make use of tabIndex in any dialog components.
   */
  let currentElement = startingElement;

  if (!includeStartingElement) {
    currentElement = elementGetter(containerElement, currentElement);
  }

  while (currentElement) {
    const thisElement = currentElement;
    if (thisElement instanceof HTMLElement) {
      if (isElementTabbable(thisElement, skipAnchors)) {
        return thisElement;
      }
    }
    currentElement = elementGetter(containerElement, thisElement);
  }

  return null;
}

export function findFirstTabbableElement(
  container: HTMLElement,
  skipAnchors?: ?boolean,
): HTMLElement | null {
  return findTabbableElement(
    container,
    container.firstElementChild ?? null,
    getNextElement,
    true,
    skipAnchors,
  );
}

export function findLastTabbableElement(
  container: HTMLElement,
): HTMLElement | null {
  const lastElement = container.lastElementChild;
  return findTabbableElement(
    container,
    lastElement
      ? findLastElementDepthFirst(lastElement)
      : null,
    getPreviousElement,
    true,
  );
}

export function handleTab(
  activeElement: HTMLElement | null,
  container: HTMLElement,
  trapFocus: boolean = false,
  event: SyntheticKeyboardEvent<HTMLElement> | null,
): HTMLElement | null {
  if (activeElement && container.contains(activeElement)) {
    const shiftKey = (event?.shiftKey) === true;
    let tabbableElement = findTabbableElement(
      container,
      activeElement,
      shiftKey ? getPreviousElement : getNextElement,
    );
    if (!tabbableElement && trapFocus) {
      tabbableElement = (
        shiftKey
          ? findLastTabbableElement
          : findFirstTabbableElement
      )(container);
      if (tabbableElement) {
        if (event != null) {
          event.preventDefault();
        }
        tabbableElement.focus();
      }
    }
    return tabbableElement;
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
