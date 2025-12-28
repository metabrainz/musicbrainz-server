/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {faPlusCircle} from '@fortawesome/free-solid-svg-icons';
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import * as React from 'react';

import {
  isAccountAdmin,
  isAdmin,
  isBannerEditor,
  isLocationEditor,
  isRelationshipEditor,
  isWikiTranscluder,
} from '../static/scripts/common/utility/privileges.js';

type EditorPropT = ?{+privileges: number, ...};

component AdminToolsDropdown(user: EditorPropT) {

  if (!isAdmin(user)) {
    return null;
  }

  return (
    <span className="dropdown">
      <a
        aria-expanded="false"
        className="dropdown-toggle editor-tools-dropdown-toggle"
        data-bs-toggle="dropdown"
        href="#"
        role="button"
      >
        <FontAwesomeIcon icon={faPlusCircle} />
        {l('Admin tools')}
      </a>
      <ul className="dropdown-menu">
        {isLocationEditor(user) ? (
          <li className="dropdown-item">
            <a href="/area/create">{l_admin('Add area')}</a>
          </li>
        ) : null}
        {isRelationshipEditor(user) ? (
          <>
            <li className="dropdown-item">
              <a href="/instrument/create">
                {l_admin('Add instrument')}
              </a>
            </li>
            <li className="dropdown-item">
              <a href="/genre/create">{l_admin('Add genre')}</a>
            </li>
            <li className="dropdown-item">
              <a href="/relationships">
                {l_admin('Edit relationship types')}
              </a>
            </li>
          </>
        ) : null}
        {isWikiTranscluder(user) ? (
          <li className="dropdown-item">
            <a href="/admin/wikidoc">
              {l_admin('Transclude WikiDocs')}
            </a>
          </li>
        ) : null}
        {isBannerEditor(user) ? (
          <li className="dropdown-item">
            <a href="/admin/banner/edit">
              {l_admin('Edit banner message')}
            </a>
          </li>
        ) : null}
        {isAccountAdmin(user) ? (
          <>
            <li className="dropdown-item">
              <a href="/admin/attributes">
                {l_admin('Edit attributes')}
              </a>
            </li>
            <li className="dropdown-item">
              <a href="/admin/statistics-events">
                {l_admin('Edit statistics events')}
              </a>
            </li>
            <li className="dropdown-item">
              <a href="/admin/email-search">
                {l_admin('Email search')}
              </a>
            </li>
            <li className="dropdown-item">
              <a href="/admin/privilege-search">
                {l_admin('Privilege search')}
              </a>
            </li>
            <li className="dropdown-item">
              <a href="/admin/locked-usernames/search">
                {l_admin('Locked username search')}
              </a>
            </li>
            <li className="dropdown-item">
              <a href="/admin/possible-spammers">
                {l_admin('Possible spammers')}
              </a>
            </li>
          </>
        ) : null}
      </ul>
    </span>
  );
}

export default AdminToolsDropdown;

