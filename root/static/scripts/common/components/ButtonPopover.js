/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  arrow,
  autoPlacement,
  FloatingArrow,
  FloatingFocusManager,
  FloatingPortal,
  FloatingTree,
  shift,
  useClick,
  useDismiss,
  useFloating,
  useFloatingParentNodeId,
  useInteractions,
} from '@floating-ui/react';
import * as React from 'react';

import {unwrapNl} from '../i18n.js';

import ErrorBoundary from './ErrorBoundary.js';

component ButtonPopover(
  buildChildren: (
    close: () => void,
    initialFocusRef: {current: HTMLElement | null},
  ) => React$Node,
  buttonContent: React$Node,
  buttonProps?: {
    className?: string,
    id?: string,
    title?: string | (() => string),
  } | null,
  className?: string,
  closeOnOutsideClick: boolean = true,
  isDisabled: boolean = false,
  isOpen: boolean,
  toggle: (boolean) => void,
  wrapButton?: (React$MixedElement) => React$MixedElement,
  ...dialogProps: {id: string}
) {
  const buttonId = buttonProps?.id;
  const buttonTitle = buttonProps?.title;

  const arrowRef = React.useRef<Element | null>(null);

  const {refs, floatingStyles, context} = useFloating({
    open: isOpen,
    onOpenChange: toggle,
    middleware: [
      autoPlacement(),
      shift(),
      arrow({element: arrowRef}),
    ],
  });

  const click = useClick(context);
  const dismiss = useDismiss(context, {
    outsidePress: closeOnOutsideClick,
    outsidePressEvent: 'click',
  });

  const {getReferenceProps, getFloatingProps} = useInteractions([
    click,
    dismiss,
  ]);

  const customButtonProps = buttonProps ? {
    className: buttonProps.className,
    id: buttonProps.id,
    title: empty(buttonProps.title)
      ? undefined
      : unwrapNl<string>(buttonProps.title),
  } : null;

  let buttonElement: React$MixedElement = (
    <button
      {...getReferenceProps()}
      {...customButtonProps}
      aria-controls={isOpen ? dialogProps.id : null}
      aria-haspopup="dialog"
      className={buttonProps?.className}
      disabled={isDisabled}
      id={buttonId}
      ref={refs.setReference}
      title={buttonTitle == null ? null : unwrapNl<string>(buttonTitle)}
      type="button"
    >
      {buttonContent}
    </button>
  );

  if (wrapButton) {
    buttonElement = wrapButton(buttonElement);
  }

  const close = React.useCallback(() => {
    toggle(false);
  }, [toggle]);

  const initialFocusRef = React.useRef<HTMLElement | null>(null);

  let popoverElement: React$MixedElement | null = isOpen ? (
    <FloatingPortal>
      <FloatingFocusManager
        closeOnFocusOut
        context={context}
        initialFocus={initialFocusRef}
        modal
        returnFocus
      >
        <div
          {...getFloatingProps()}
          className={
            'dialog popover' +
            (nonEmpty(className) ? ' ' + className : '')
          }
          id={dialogProps.id}
          ref={refs.setFloating}
          role="dialog"
          style={floatingStyles}
        >
          <ErrorBoundary>
            {/* $FlowIgnore[react-rule-unsafe-ref] */}
            {buildChildren(close, initialFocusRef)}
          </ErrorBoundary>
          <FloatingArrow
            context={context}
            fill="currentColor"
            height={12}
            ref={arrowRef}
            stroke="#AAA"
            strokeWidth={1}
            width={24}
          />
        </div>
      </FloatingFocusManager>
    </FloatingPortal>
  ) : null;

  const floatingParentNodeId = useFloatingParentNodeId();

  if (floatingParentNodeId === null) {
    popoverElement = (
      <FloatingTree>
        {popoverElement}
      </FloatingTree>
    );
  }
  return (
    <>
      {buttonElement}
      {popoverElement}
    </>
  );
}

export default ButtonPopover;
