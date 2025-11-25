/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  faChevronDown,
  faChevronUp,
  faPlusCircle,
} from '@fortawesome/free-solid-svg-icons';
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import * as React from 'react';

import {SanitizedCatalystContext} from '../../../context.mjs';
import {VARTIST_GID} from '../common/constants.js';
import useMediaQuery from '../common/hooks/useMediaQuery.js';
import {l, lp} from '../common/i18n.js';

const editorToolsItems = [
  {
    context: 'interactive',
    href: '/artist/create',
    label: 'Add artist',
  },
  {
    context: 'interactive',
    href: '/label/create',
    label: 'Add label',
  },

  {
    context: 'interactive',
    href: '/release-group/create',
    label: 'Add release group',
  },

  {
    context: 'interactive',
    href: '/release/add',
    label: 'Add release',
  },

  {
    context: 'interactive',
    href: '/release/add?artist=' + encodeURIComponent(VARTIST_GID),
    label: 'Add Various Artists release',
  },

  {
    context: 'interactive',
    href: '/recording/create',
    label: 'Add standalone recording',
  },

  {
    context: 'interactive',
    href: '/work/create',
    label: 'Add work',
  },

  {
    context: 'interactive',
    href: '/place/create',
    label: 'Add place',
  },

  {
    context: 'singular, interactive',
    href: '/series/create',
    label: 'Add series',
  },

  {
    context: 'interactive',
    href: '/event/create',
    label: 'Add event',
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
    <div className="editor-tools-container layout-width">
      <button
        aria-controls="editorToolsCollapse"
        aria-expanded={isExpanded ? 'true' : 'false'}
        className="editor-tools-button"
        data-bs-target="#editorToolsCollapse"
        data-bs-toggle="collapse"
        type="button"
      >
        <FontAwesomeIcon icon={faChevronDown} />
        {l('Editor Tools')}
      </button>

      <div
        className={`collapse ${isExpanded ? 'show' : ''}`}
        id="editorToolsCollapse"
      >
        <div className="editor-tools-content">
          <div className="editor-tools-cell" id="editor-tools-cell-1">
            <div className="editor-tools-cell-sub">
              <a href={`/user/${user.name}`}>{l('My Profile')}</a>
              <a href="/logout">{l('Logout')}</a>
            </div>
            <div className="editor-tools-cell-sub">
              <a href="/account/applications">{l('Applications')}</a>
              <a href={`/user/${user.name}/subscriptions/artist`}>
                {l('Subscriptions')}
              </a>
            </div>
          </div>
          <div className="editor-tools-cell" id="editor-tools-cell-2">
            <a href={`/user/${user.name}/collections`}>
              {l('My collections')}
            </a>
            <a href={`/user/${user.name}/ratings`}>{l('My ratings')}</a>
            <a href={`/user/${user.name}/tags`}>{l('My tags')}</a>
          </div>
          <div className="editor-tools-cell" id="editor-tools-cell-3">
            <a href={`/user/${user.name}/edits/open`}>
              {l('My open edits')}
            </a>
            <a href={`/user/${user.name}/edits`}>{l('All my edits')}</a>
            <a href="/edit/subscribed">{l('Subscribed entity edits')}</a>
            <a href="/edit/subscribed_editors">
              {l('Subscribed editor edits')}
            </a>
          </div>
          <div className="editor-tools-cell" id="editor-tools-cell-4">
            <a href="/edit/notes-received">
              {l('Notes left on my edits')}
            </a>
          </div>
          <div className="editor-tools-cell" id="editor-tools-cell-5">
            <a href="/vote">{l('Votes on edits')}</a>
            <a href="/reports">{l('My reports')}</a>
          </div>
          <div className="editor-tools-cell" id="editor-tools-cell-6">
            <span className="dropdown">
              <a
                aria-expanded="false"
                className="dropdown-toggle editor-tools-dropdown-toggle"
                data-bs-toggle="dropdown"
                href="#"
                role="button"
              >
                <FontAwesomeIcon icon={faPlusCircle} />
                {l('Add new...')}
              </a>
              <ul className="dropdown-menu">
                {editorToolsItems.map((item) => (
                  <li className="dropdown-item" key={item.label}>
                    <a href={item.href}>
                      {item.context === undefined
                        ? l(item.label)
                        : lp(item.label, item.context)}
                    </a>
                  </li>
                ))}
              </ul>
            </span>
          </div>
          <button
            aria-controls="editorToolsCollapse"
            aria-expanded={isExpanded ? 'true' : 'false'}
            className="close-editor-tools-button d-sm-none"
            data-bs-target="#editorToolsCollapse"
            data-bs-toggle="collapse"
            type="button"
          >
            <FontAwesomeIcon color="white" icon={faChevronUp} size="xl" />
          </button>
        </div>
      </div>
    </div>
  );
}

export default (hydrate<React.PropsOf<EditorTools>>(
  'div.editor-tools',
  EditorTools,
): component(...React.PropsOf<EditorTools>));
