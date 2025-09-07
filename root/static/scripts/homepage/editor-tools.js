/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from "react";
import {SanitizedCatalystContext} from '../../../context.mjs';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faChevronDown, faPlusCircle } from '@fortawesome/free-solid-svg-icons';
import useMediaQuery from '../common/hooks/useMediaQuery';
import {VARTIST_GID} from '../common/constants';

const editorToolsItems = [
  {
    label: 'Add artist',
    href: '/artist/create',
    context: 'interactive',
  },
  {
    label: 'Add label',
    href: '/label/create',
    context: 'interactive',
  },
  
  {
    label: 'Add release group',
    href: '/release-group/create',
    context: 'interactive',
  },
  
  {
    label: 'Add release',
    href: '/release/add',
    context: 'interactive',
  },
  
  {
    label: 'Add Various Artists release',
    href: '/release/add?artist=' + encodeURIComponent(VARTIST_GID),
    context: 'interactive',
  },
  
  {
    label: 'Add standalone recording',
    href: '/recording/create',
    context: 'interactive',
  },
  
  {
    label: 'Add work',
    href: '/work/create',
    context: 'interactive',
  },
  
  {
    label: 'Add place',
    href: '/place/create',
    context: 'interactive',
  },
  
  {
    label: 'Add series',
    href: '/series/create',
    context: 'singular, interactive',
  },
  
  {
    label: 'Add event',
    href: '/event/create',
    context: 'interactive',
  },
];

component EditorTools() {
  const $c = React.useContext(SanitizedCatalystContext);
  const user = $c.user;

  const isMobile = useMediaQuery('(max-width: 992px)');
  const [isHydrated, setIsHydrated] = React.useState(false);

  React.useEffect(() => {
    setIsHydrated(true);
  }, []);

  if (!user) {
    return null;
  }

  const isExpanded = isHydrated ? !isMobile : false;

  return (
    <div className="editor-tools-container">
      <button
        className="editor-tools-button"
        type="button"
        data-bs-toggle="collapse"
        data-bs-target="#editorToolsCollapse"
        aria-expanded={isExpanded ? "true" : "false"}
        aria-controls="editorToolsCollapse"
      >
        <FontAwesomeIcon icon={faChevronDown} />
        Editor Tools
      </button>

      <div className={`collapse ${isExpanded ? "show" : ""}`} id="editorToolsCollapse">
        <div className="editor-tools-content">
          <div className="editor-tools-cell" id="editor-tools-cell-1">
            <div className="editor-tools-cell-sub">
              <a href={`/user/${user.name}`}>My Profile</a>
              <a href="/logout">Logout</a>
            </div>
            <div className="editor-tools-cell-sub">
              <a href="/account/applications">Applications</a>
              <a href={`/user/${user.name}/subscriptions/artist`}>Subscriptions</a>
            </div>
          </div>
          <div className="editor-tools-cell" id="editor-tools-cell-2">
            <a href={`/user/${user.name}/collections`}>My collections</a>
            <a href={`/user/${user.name}/ratings`}>My ratings</a>
            <a href={`/user/${user.name}/tags`}>My tags</a>
          </div>
          <div className="editor-tools-cell" id="editor-tools-cell-3">
            <a href={`/user/${user.name}/edits/open`}>My open edits</a>
            <a href={`/user/${user.name}/edits`}>All my edits</a>
            <a href="/edit/subscribed">Subscribed entity edits</a>
            <a href="/edit/subscribed_editors">Subscribed editor edits</a>
          </div>
          <div className="editor-tools-cell" id="editor-tools-cell-4">
            <a href="/edit/notes-received">Notes left on my edits</a>
          </div>
          <div className="editor-tools-cell" id="editor-tools-cell-5">
            <a href="/vote">Votes on edits</a>
            <a href="/reports">My reports</a>
          </div>
          <div className="editor-tools-cell" id="editor-tools-cell-6">
            <span className="dropdown">
              <a
                className="dropdown-toggle editor-tools-dropdown-toggle"
                href="#"
                role="button"
                data-bs-toggle="dropdown"
                aria-expanded="false"
              >
                <FontAwesomeIcon icon={faPlusCircle} />
                Add new...
              </a>
              <ul className="dropdown-menu">
                {editorToolsItems.map((item) => (
                  <li className="dropdown-item" key={item.label}>
                    <a href={item.href}>
                      {item.context !== undefined ? lp(item.label, item.context) : l(item.label)}
                    </a>
                  </li>
                ))}
              </ul>
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default (hydrate<React.PropsOf<EditorTools>> (
  'div.editor-tools',
  EditorTools,
): component(...React.PropsOf<EditorTools>));
