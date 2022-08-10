/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import arrow from '@popperjs/core/lib/modifiers/arrow.js';
import flip from '@popperjs/core/lib/modifiers/flip.js';
import offset from '@popperjs/core/lib/modifiers/offset.js';
import preventOverflow from '@popperjs/core/lib/modifiers/preventOverflow.js';
import {createPopper} from '@popperjs/core/lib/popper-lite.js';
import * as React from 'react';
import {createPortal} from 'react-dom';

import Dialog, {
  getDialogRootNode,
  getElementFromRef,
} from './Dialog.js';

const POPPER_OPTIONS = {
  modifiers: [
    {
      enabled: false,
      name: 'eventListeners',
    },
    flip,
    preventOverflow,
    arrow,
    {
      ...offset,
      options: {
        offset: () => [0, 12],
      },
    },
  ],
  placement: 'right',
};

type PropsT = {
  +buildChildren: (() => void) => React.Node,
  +buttonRef: {current: HTMLButtonElement | null},
  +className?: string,
  +closeAndReturnFocus: () => void,
  +dialogRef: {current: HTMLDivElement | null},
  +id: string,
};

const Popover = (props: PropsT): React.Portal => {
  const {
    buildChildren,
    buttonRef,
    closeAndReturnFocus,
    dialogRef,
    ...dialogProps
  } = props;

  React.useLayoutEffect(() => {
    const popper = createPopper(
      buttonRef.current,
      getElementFromRef(dialogRef),
      POPPER_OPTIONS,
    );
    return () => {
      popper.destroy();
    };
  }, [dialogRef, buttonRef]);

  return createPortal(
    <Dialog
      {...dialogProps}
      className="popover"
      dialogRef={dialogRef}
      onEscape={closeAndReturnFocus}
      siblings={<div data-popper-arrow />}
      trapFocus={false}
    >
      {buildChildren(closeAndReturnFocus)}
    </Dialog>,
    getDialogRootNode(dialogProps.id),
  );
};

export default Popover;
