/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import UserAccountLayout, {
  type AccountLayoutUserT,
} from '../components/UserAccountLayout';
import EditorLink from '../static/scripts/common/components/EditorLink';
import {UserTagLink} from '../static/scripts/common/components/TagLink';
import loopParity from '../utility/loopParity';

import {AllDownvotedSwitch} from './components/DownvotedSwitch';

type Props = {
  +$c: CatalystContextT,
  +genres: $ReadOnlyArray<UserTagT>,
  +showDownvoted?: boolean,
  +tags: $ReadOnlyArray<UserTagT>,
  +user: AccountLayoutUserT,
};

const UserTagList = ({
  $c,
  genres,
  showDownvoted = false,
  tags,
  user,
}: Props): React.Element<typeof UserAccountLayout> => (
  <UserAccountLayout $c={$c} entity={user} page="tags" title={l('Tags')}>

    <AllDownvotedSwitch $c={$c} showDownvoted={showDownvoted} user={user} />

    <div id="all-tags">
      {(genres.length > 0 || tags.length > 0) ? (
        <>
          <h2>{l('Genres')}</h2>

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

          <h2>{l('Other tags')}</h2>

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
            ) : <p>{l('There are no other tags to show.')}</p>}
          </div>
        </>
      ) : (
        showDownvoted ? (
          <p>
            {exp.l(
              '{user} has not voted against any tags.',
              {user: <EditorLink editor={user} />},
            )}
          </p>
        ) : (
          <p>
            {exp.l(
              '{user} has not tagged anything.',
              {user: <EditorLink editor={user} />},
            )}
          </p>
        )
      )}
    </div>

  </UserAccountLayout>
);

export default UserTagList;
