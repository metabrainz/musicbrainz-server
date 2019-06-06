/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import useDropdown from '../../static/scripts/common/hooks/useDropdown';

type Props = {
  children: React$Node,
  className: string,
  id: string,
  label: string,
};

const MenuDropdown = (props: Props) => {
  const dropdown = useDropdown();

  return (
    <li
      className={props.className + ' nav-item dropdown'}
      ref={dropdown.dropdownRef}
    >
      <a
        aria-expanded={String(dropdown.expanded)}
        aria-haspopup="true"
        className="nav-link dropdown-toggle"
        href="#"
        id={props.id}
        onClick={dropdown.handleToggle}
        onKeyDown={dropdown.handleKeyEvent}
        ref={dropdown.buttonRef}
        role="button"
      >
        {props.label}
      </a>
      <div
        aria-labelledby={props.id}
        className={'dropdown-menu' + (dropdown.expanded ? ' show' : '')}
        onKeyDown={dropdown.handleKeyEvent}
        ref={dropdown.menuRef}
      >
        {props.children}
      </div>
    </li>
  );
};

export default MenuDropdown;
