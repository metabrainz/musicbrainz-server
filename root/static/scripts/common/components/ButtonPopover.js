/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import useOutsideClickEffect from '../hooks/useOutsideClickEffect.js';
import useReturnFocus from '../hooks/useReturnFocus.js';
import {unwrapNl} from '../i18n.js';

import Popover from './Popover.js';

type PropsT = {
  +buildChildren: (() => void) => React.Node,
  +buttonContent: React.Node,
  +buttonProps?: {
    className?: string,
    title?: string | (() => string),
  },
  +buttonRef: {current: HTMLButtonElement | null},
  +className?: string,
  +id: string,
  +isOpen: boolean,
  +toggle: (boolean) => void,
};

const ButtonPopover = (props: PropsT): React.MixedElement => {
  const {
    buttonContent,
    buttonProps = null,
    buttonRef,
    isOpen,
    toggle,
    ...dialogProps
  } = props;
  const buttonTitle = buttonProps?.title;

  const dialogRef = React.useRef<HTMLDivElement | null>(null);

  useOutsideClickEffect(
    dialogRef,
    (event) => {
      /*
       * Clicking the opener again registers as an outside
       * click, but is already handled separately.
       */
      if (event.target !== buttonRef.current) {
        /*
         * Don't return focus here, since the user maybe be clicking
         * on an unrelated field in the page.
         */
        toggle(false);
      }
    },
  );

  const returnFocusToButton = useReturnFocus(buttonRef);

  /*
   * Triggered when the user (1) toggles the opener button,
   * (2) hits escape, or (3) tabs out. Returns focus to the opening
   * button in all three cases.
   */
  const closeAndReturnFocus = React.useCallback(() => {
    returnFocusToButton.current = true;
    toggle(false);
  }, [returnFocusToButton, toggle]);

  return (
    <>
      <button
        aria-controls={isOpen ? dialogProps.id : null}
        aria-haspopup="dialog"
        className={buttonProps?.className}
        onClick={() => {
          if (isOpen) {
            closeAndReturnFocus();
          } else {
            toggle(true);
          }
        }}
        ref={buttonRef}
        title={buttonTitle == null ? null : unwrapNl(buttonTitle)}
        type="button"
      >
        {buttonContent}
      </button>
      {isOpen
        ? (
          <Popover
            buttonRef={buttonRef}
            closeAndReturnFocus={closeAndReturnFocus}
            dialogRef={dialogRef}
            {...dialogProps}
          />
        )
        : null}
    </>
  );
};

export default ButtonPopover;
