/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import UserAccountLayout, {
  type AccountLayoutUserT,
} from '../components/UserAccountLayout.js';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import {UserTagLink} from '../static/scripts/common/components/TagLink.js';
import expand2react from '../static/scripts/common/i18n/expand2react.js';
import loopParity from '../utility/loopParity.js';

import UserTagFilters from './components/UserTagFilters.js';

const headingsText: {+[vote: string]: () => string} = {
  down: N_lp('Tags {user} downvoted', 'folksonomy'),
  up: N_lp('Tags {user} upvoted', 'folksonomy'),
};

export function getTagListHeading(
  user: string,
  showDownvoted: boolean,
): Expand2ReactOutput {
  return expand2react(
    headingsText[showDownvoted ? 'down' : 'up'](),
    {user},
  );
}

export function getTagListUrl(
  user: string,
  showDownvoted: boolean,
): string {
  return (
    '/user/' +
    encodeURIComponent(user) +
    '/tags?show_downvoted=' + (showDownvoted ? '1' : '0')
  );
}

component UserTagList(
  genres: $ReadOnlyArray<UserTagT>,
  showDownvoted: boolean = false,
  sortBy?: 'count' | 'countdesc' | 'name',
  tags: $ReadOnlyArray<UserTagT>,
  user: AccountLayoutUserT,
) {
  return (
    <UserAccountLayout
      entity={user}
      page="tags"
      title={lp('Tags', 'folksonomy')
      }
    >
      <h2>
        {getTagListHeading(user.name, showDownvoted)}
      </h2>

      <UserTagFilters
        showDownvoted={showDownvoted}
        showSortSelect
        showVotesSelect
        sortBy={sortBy}
      />

      <div id="all-tags">
        {(genres.length > 0 || tags.length > 0) ? (
          <>
            <h3>{l('Genres')}</h3>

            <div id="genres">
              {genres.length > 0 ? (
                <ul className="genre-list">
                  {genres.map((tag, index) => (
                    <li className={loopParity(index)} key={tag.tag.id}>
                      <UserTagLink
                        showDownvoted={showDownvoted}
                        tag={tag.tag.name}
                        username={user.name}
                      />
                      <span className="tag-vote-buttons">
                        <span className="tag-count">{tag.count}</span>
                      </span>
                    </li>
                  ))}
                </ul>
              ) : <p>{l('There are no genres to show.')}</p>}
            </div>

            <h3>{lp('Other tags', 'folksonomy')}</h3>

            <div id="tags">
              {tags.length > 0 ? (
                <ul className="tag-list">
                  {tags.map((tag, index) => (
                    <li className={loopParity(index)} key={tag.tag.id}>
                      <UserTagLink
                        showDownvoted={showDownvoted}
                        tag={tag.tag.name}
                        username={user.name}
                      />
                      <span className="tag-vote-buttons">
                        <span className="tag-count">{tag.count}</span>
                      </span>
                    </li>
                  ))}
                </ul>
              ) : (
                <p>
                  {lp('There are no other tags to show.', 'folksonomy')}
                </p>
              )}
            </div>
          </>
        ) : (
          showDownvoted ? (
            <p>
              {exp.l(
                '{user} has not downvoted any tags.',
                {user: <EditorLink editor={user} />},
              )}
            </p>
          ) : (
            <p>
              {exp.l(
                '{user} has not upvoted any tags.',
                {user: <EditorLink editor={user} />},
              )}
            </p>
          )
        )}
      </div>
    </UserAccountLayout>
  );
}

export default UserTagList;
