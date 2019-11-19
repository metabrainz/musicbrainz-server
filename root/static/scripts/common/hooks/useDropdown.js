/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import noop from 'lodash/noop';
import {useLayoutEffect, useRef, useState} from 'react';

import useOutsideClickEffect from './useOutsideClickEffect';

type ElementRef = {
  current: HTMLElement | null,
};

type Instance = {
  buttonRef: ElementRef,
  close: () => void,
  dropdownRef: ElementRef,
  expanded: boolean,
  focusItem: (-1 | 1) => void,
  handleKeyEvent: (SyntheticKeyboardEvent<HTMLElement>) => void,
  handleToggle: (SyntheticKeyboardEvent<HTMLElement>) => void,
  menuRef: ElementRef,
  positionMenu: () => void,
};

const SSR_INSTANCE = {
  buttonRef: {current: null},
  close: noop,
  dropdownRef: {current: null},
  expanded: false,
  focusItem: noop,
  handleKeyEvent: noop,
  handleToggle: noop,
  menuRef: {current: null},
  positionMenu: noop,
};

function isHtmlElement(element: ?Element): boolean %checks {
  return element instanceof HTMLElement;
}

function isDropdownItem(element: Element): boolean %checks {
  return isHtmlElement(element) &&
    element.classList.contains('dropdown-item');
}

function maybeFocus(element: ?Element) {
  if (isHtmlElement(element)) {
    element.focus();
  }
}

export default function useDropdown(): Instance {
  // Skip expensive/useless operations for SSR.
  if (typeof document === 'undefined') {
    return SSR_INSTANCE;
  }

  const [expanded, setExpanded] = useState(false);
  const dropdownRef = useRef<HTMLElement | null>(null);
  const buttonRef = useRef<HTMLElement | null>(null);
  const menuRef = useRef<HTMLElement | null>(null);
  const instanceRef = useRef<Instance | null>(null);

  const instance = instanceRef.current || (instanceRef.current = {
    buttonRef,

    close() {
      if (instance.expanded) {
        setExpanded(false);
      }
    },

    dropdownRef,

    expanded: false,

    focusItem(direction: -1 | 1) {
      const menu = menuRef.current;
      if (menu) {
        const active = document.activeElement;
        if (active && active.parentElement === menuRef.current) {
          let target = active;
          while (true) {
            target = direction < 0
              ? target.previousElementSibling
              : target.nextElementSibling;
            if (!target) {
              break;
            }
            if (isDropdownItem(target)) {
              target.focus();
              break;
            }
          }
        } else if (direction < 0) {
          maybeFocus(menu.lastElementChild);
        } else {
          maybeFocus(menu.firstElementChild);
        }
      }
    },

    handleKeyEvent(event: SyntheticKeyboardEvent<HTMLElement>) {
      switch (event.key) {
        case 'ArrowUp':
          event.preventDefault();
          if (instance.expanded) {
            instance.focusItem(-1);
          } else {
            setExpanded(true);
          }
          break;

        case 'ArrowDown':
          event.preventDefault();
          if (instance.expanded) {
            instance.focusItem(1);
          } else {
            setExpanded(true);
          }
          break;

        case ' ':
          instance.handleToggle(event);
          break;

        case 'Escape':
          if (buttonRef.current) {
            buttonRef.current.focus();
          }
        case 'Tab':
          instance.close();
          break;
      }
    },

    handleToggle(event: SyntheticKeyboardEvent<HTMLElement>) {
      event.preventDefault();
      setExpanded(prevExpanded => !prevExpanded);
    },

    menuRef,

    positionMenu() {
      const documentElement = document.documentElement;
      const button = buttonRef.current;
      const menu = menuRef.current;

      if (documentElement && button && menu) {
        if (menu.getBoundingClientRect().right >
              documentElement.clientWidth) {
          menu.style.left = '-' +
            String(menu.offsetWidth - button.offsetWidth) + 'px';
        }
      }
    },
  });

  instance.expanded = expanded;

  useOutsideClickEffect(dropdownRef, instance.close);

  useLayoutEffect(instance.positionMenu);

  return instance;
}
