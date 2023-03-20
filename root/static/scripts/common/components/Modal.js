/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import {createPortal} from 'react-dom';

import useEventTrap from '../hooks/useEventTrap.js';

import Dialog, {
  type RequiredPropsT as DialogPropsT,
  getDialogRootNode,
  getElementFromRef,
} from './Dialog.js';

type PropsT = $ReadOnly<{
  ...DialogPropsT,
  +className?: string,
  +onClick?: (SyntheticMouseEvent<HTMLDivElement>) => void,
  +title: string,
}>;

const Modal = (props: PropsT): React$Portal => {
  const {
    className,
    dialogRef,
    id,
  } = props;

  const activeElementRef = React.useRef<HTMLElement | null>(null);

  const returnFocusToDialog = (event: Event) => {
    const dialogNode = getElementFromRef(dialogRef);
    event.preventDefault();
    const activeElement = activeElementRef.current ?? dialogNode;
    activeElement.focus();
  };

  useEventTrap(
    'focusin',
    dialogRef,
    returnFocusToDialog,
  );

  useEventTrap(
    'keydown',
    dialogRef,
    returnFocusToDialog,
  );

  React.useLayoutEffect(() => {
    const dialogNodeStyle = getElementFromRef(dialogRef).style;
    dialogNodeStyle.top = String(window.scrollY + 16) + 'px';
  });

  return createPortal(
    <>
      <div
        className="modal-backdrop"
        onClick={returnFocusToDialog}
      />
      <Dialog
        {...props}
        activeElementRef={activeElementRef}
        className={'modal ' + (className ?? '')}
        trapFocus
      />
    </>,
    getDialogRootNode(id),
  );
};

export default Modal;
