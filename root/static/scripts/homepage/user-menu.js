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
    <>
      {user && (
        <>
          <div>
            <h2>{l('Welcome back')}</h2>
            <a href={`/user/${user?.name}`} className="username-link">
              <h2 className="username">
                {user?.name}
              </h2>
            </a>
          </div>
          <div className="user-menu-columns">
            <div className="user-menu-column">
              <a href="https://community.metabrainz.org/" target="_blank" rel="noopener noreferrer">
                {l('Forums')}
              </a>
              <a href="/doc/Communication/ChatBrainz">
                {l('Chat')}
              </a>
            </div>
            <div className="user-menu-column">
              <a href="https://tickets.metabrainz.org/" target="_blank" rel="noopener noreferrer">
                {l('Ticket tracker')}
              </a>
              <a href="/doc/Style">
                {l('Editing guidelines')}
              </a>
            </div>
            <div className="user-menu-column">
              <a href="https://wiki.musicbrainz.org/Guides/Userscripts" target="_blank" rel="noopener noreferrer">
                {l('Userscripts')}
              </a>
            </div>
            {latestBlogPost && (
              <div className="user-menu-column">
                <span>Latest blog post:</span>
                <a href={latestBlogPost.url} target="_blank" rel="noopener noreferrer">
                  {latestBlogPost.title}
                </a>
              </div>
            )}
          </div>
        </>
      )}
    </>
  );
}

export default (hydrate<React.PropsOf<UserMenu>> (
  'div.user-menu',
  UserMenu,
): component(...React.PropsOf<UserMenu>));
