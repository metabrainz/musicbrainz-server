/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import he from 'he';
import * as React from 'react';

import {SanitizedCatalystContext} from '../../../context.mjs';

type BlogEntryT = {
  +title: string,
  +url: string,
};

component UserMenu(
  latestBlogPost: BlogEntryT | null,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  const user = $c.user;

  return (
    <div className="user-menu-container">
      {user && (
        <>
          <div className="welcome-message">
            {exp.l('Welcome back<br />{username}', {
              username: (
                <a
                  className="username-link username"
                  href={`/user/${user?.name}`}
                >
                  {user?.name}
                </a>
              ),
            })}
          </div>
          <div className="user-menu-columns">
            <div className="user-menu-column">
              <a href="https://community.metabrainz.org/">
                {l('Community forums')}
              </a>
              <a href="/doc/Communication/ChatBrainz">
                {l('Chat')}
              </a>
            </div>
            <div className="user-menu-column">
              <a href="https://tickets.metabrainz.org/">
                {l('Ticket tracker')}
              </a>
              <a href="/doc/Style">
                {l('Style guidelines')}
              </a>
            </div>
            <div className="user-menu-column">
              <a href="https://wiki.musicbrainz.org/Guides/Userscripts">
                {l('Userscripts')}
              </a>
            </div>
            {latestBlogPost && (
              <div className="user-menu-column">
                <span>{l('Latest blog post:')}</span>
                <a href={latestBlogPost.url}>
                  {he.decode(latestBlogPost.title)}
                </a>
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
}

export default (hydrate<React.PropsOf<UserMenu>>(
  'div.user-menu',
  UserMenu,
): component(...React.PropsOf<UserMenu>));
