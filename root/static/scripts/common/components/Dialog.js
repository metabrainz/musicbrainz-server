/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  detectIfAnchorIsTabbable,
  findFirstTabbableElement,
  handleTabKeyPress,
} from '../utility/focusManagement.js';

import ErrorBoundary from './ErrorBoundary.js';

export type RequiredPropsT = {
  +children: React.Node,
  +dialogRef: {current: HTMLDivElement | null},
  +id: string,
  +onEscape: (Event | SyntheticEvent<>) => void,
};

export type PropsT = $ReadOnly<{
  ...RequiredPropsT,
  +activeElementRef?: {-current: HTMLElement},
  +className?: string,
  +onClick?: (SyntheticMouseEvent<HTMLDivElement>) => void,
  +siblings?: React.Node,
  // Set `title` to a non-null value to show the title bar.
  +title?: string,
  +trapFocus?: boolean,
}>;

function stopPropagation(event: Event) {
  event.stopPropagation();
}

export function getDialogRootNode(
  id: string,
): HTMLDivElement {
  const rootId = id + '-root';
  let dialogRoot = document.getElementById(rootId);
  if (dialogRoot) {
    if (!(dialogRoot instanceof HTMLDivElement)) {
      throw new Error('Dialog root <div> not found');
    }
  } else {
    dialogRoot = document.createElement('div');
    dialogRoot.setAttribute('id', rootId);
    dialogRoot.classList.add('dialog-root');
    dialogRoot.addEventListener('click', stopPropagation);
    dialogRoot.addEventListener('mouseup', stopPropagation);
    dialogRoot.addEventListener('mousedown', stopPropagation);
    document.body?.appendChild(dialogRoot);
  }
  return dialogRoot;
}

export function getElementFromRef<T: HTMLElement>(
  ref: {current: T | null},
): T {
  const element = ref.current;
  if (!element) {
    throw new Error('Ref is null');
  }
  return element;
}

const Dialog = ({
  activeElementRef,
  children,
  className,
  dialogRef,
  id,
  onClick,
  onEscape,
  siblings,
  title,
  trapFocus = false,
}: PropsT): React.Element<'div'> => {
  const tabbableElementRef = React.useRef(null);

  React.useLayoutEffect(() => {
    const dialogNode = getElementFromRef(dialogRef);
    dialogNode.style.visibility = 'visible';
    dialogNode.removeAttribute('aria-hidden');

    /*
     * The delay prevents iOS 14 from scrolling to (0, 0) and auto-opening
     * the <select> options list.
     */
    const tid = setTimeout(() => {
      const toFocus = findFirstTabbableElement(
        dialogNode,
        true, /* skipAnchors */
      );
      if (toFocus) {
        toFocus.focus();
      }
    }, 1);

    return () => {
      clearTimeout(tid);
      dialogNode.style.visibility = 'hidden';
      dialogNode.setAttribute('aria-hidden', 'true');
    };
  }, [dialogRef, id]);

  const handleFocus = React.useCallback((
    event: SyntheticKeyboardEvent<HTMLElement>,
  ) => {
    const eventTarget = event.target;
    if (activeElementRef && eventTarget instanceof HTMLElement) {
      activeElementRef.current = eventTarget;
    }
    detectIfAnchorIsTabbable(
      event,
      tabbableElementRef.current,
    );
  }, [activeElementRef]);

  const handleKeyDown = React.useCallback((
    event: SyntheticKeyboardEvent<HTMLInputElement | HTMLSelectElement>,
  ) => {
    if (event.defaultPrevented) {
      return false;
    }

    switch (event.key) {
      case 'Tab': {
        /*
         * Prevent the Tab keydown from propagating to parent dialogs,
         * e.g. "Add a new artist" (child) -> "Add Relationship" (parent).
         * This is possible because React bubbles events through portals:
         * https://reactjs.org/docs/portals.html#event-bubbling-through-portals
         */
        event.stopPropagation();

        const dialogNode = getElementFromRef(dialogRef);
        const tabbableElement = handleTabKeyPress(
          event,
          dialogNode,
          trapFocus,
        );
        tabbableElementRef.current = tabbableElement;
        if (!tabbableElement) {
          /*
           * Prevent focus from moving to whatever element is next in the
           * document order, so that the handler can decide what to do.
           */
          event.preventDefault();
          onEscape(event);
        }
        break;
      }
      case 'Escape': {
        event.stopPropagation();
        onEscape(event);
        break;
      }
    }

    return true;
  }, [
    dialogRef,
    onEscape,
    trapFocus,
  ]);

  const handleKeyUp = React.useCallback(() => {
    tabbableElementRef.current = null;
  }, []);

  return (
    <div
      className={'dialog' + (nonEmpty(className) ? ' ' + className : '')}
      id={id}
      onClick={onClick}
      onFocus={handleFocus}
      onKeyDown={handleKeyDown}
      onKeyUp={handleKeyUp}
      ref={dialogRef}
      role="dialog"
      /*
       * The negative tab index ensures that clicking the dialog keeps focus
       * inside the dialog, and doesn't return it to the <body>.
       */
      tabIndex="-1"
    >
      {title == null ? null : (
        <div className="title-bar">
          <h1>{title}</h1>
          <button
            className="close-dialog icon"
            onClick={onEscape}
            type="button"
          />
        </div>
      )}
      <div className="dialog-content">
        <ErrorBoundary>
          {children}
        </ErrorBoundary>
      </div>
      {siblings}
    </div>
  );
};

export default Dialog;
