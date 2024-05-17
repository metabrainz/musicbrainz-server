/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  FloatingFocusManager,
  FloatingNode,
  FloatingOverlay,
  FloatingPortal,
  useDismiss,
  useFloating,
  useFloatingNodeId,
  useInteractions,
} from '@floating-ui/react';
import * as React from 'react';

import {expect} from '../../../../utility/invariant.js';
import {findFirstTabbableElement} from '../utility/focusManagement.js';

import ErrorBoundary from './ErrorBoundary.js';

component Modal(
  children: React$Node,
  className?: string,
  id: string,
  onEscape: (Event) => void,
  title: string,
) {
  const nodeId = useFloatingNodeId();

  const onOpenChange = React.useCallback((
    isOpen: boolean,
    event: Event,
  ) => {
    if (!isOpen) {
      onEscape(event);
    }
  }, [onEscape]);

  const {refs, context} = useFloating({
    nodeId,
    onOpenChange,
    open: true,
    strategy: 'fixed',
  });

  const dismiss = useDismiss(context, {
    bubbles: false,
    escapeKey: true,
    outsidePress: false,
  });

  const {getFloatingProps} = useInteractions([
    dismiss,
  ]);

  const handleOverlayClick = React.useCallback((
    event: SyntheticMouseEvent<HTMLDivElement>,
  ) => {
    event.stopPropagation();
    refs.floating.current?.focus();
  }, [refs.floating]);

  const initialFocusRef = React.useRef<HTMLElement | null>(null);

  React.useEffect(() => {
    const floatingDiv = refs.floating.current;
    if (!floatingDiv) {
      return;
    }
    let container = expect(
      floatingDiv.querySelector('.dialog-content'),
      '.dialog-content node',
    );
    initialFocusRef.current = findFirstTabbableElement(
      container,
      /* skipAnchors = */ true,
    );
  });

  return (
    <FloatingNode id={nodeId}>
      <FloatingPortal id={id}>
        <FloatingOverlay
          className="modal-backdrop"
          lockScroll
          onClick={handleOverlayClick}
        >
          <FloatingFocusManager
            context={context}
            initialFocus={initialFocusRef}
            modal
          >
            <div
              {...getFloatingProps()}
              className={
                'dialog modal' + (nonEmpty(className) ? ' ' + className : '')
              }
              id={id}
              ref={refs.setFloating}
              role="dialog"
              /*
               * The negative tab index ensures that clicking the dialog
               * keeps focus inside the dialog, and doesn't return it to
               * the <body>.
               */
              tabIndex="-1"
            >
              <div className="title-bar">
                <h1>{title}</h1>
                <button
                  className="close-dialog icon"
                  onClick={onEscape}
                  type="button"
                />
              </div>
              <div className="dialog-content">
                <ErrorBoundary>
                  {children}
                </ErrorBoundary>
              </div>
            </div>
          </FloatingFocusManager>
        </FloatingOverlay>
      </FloatingPortal>
    </FloatingNode>
  );
}

export default Modal;
