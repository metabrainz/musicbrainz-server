/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import {createPortal} from 'react-dom';

import useEventTrap from '../hooks/useEventTrap';

import Dialog, {
  getDialogRootNode,
  getElementFromRef,
  type RequiredPropsT as DialogPropsT,
} from './Dialog';

const Modal = (props: DialogPropsT): React.Portal => {
  const {dialogRef, id} = props;

  const activeElementRef = React.useRef<HTMLElement | null>(null);

  const returnFocusToDialog = (event) => {
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
    const {scrollX, scrollY} = window;

    const dialogNode = getElementFromRef(dialogRef);
    dialogNode.style.left = String(scrollX + 16) + 'px';
    dialogNode.style.top = String(scrollY + 16) + 'px';
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
        className="modal"
        trapFocus
      />
    </>,
    getDialogRootNode(id),
  );
};

export default Modal;
