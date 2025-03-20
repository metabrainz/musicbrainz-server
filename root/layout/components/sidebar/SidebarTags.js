/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context.mjs';
import EntityLink
  from '../../../static/scripts/common/components/EntityLink.js';
import {SidebarTagEditor}
  from '../../../static/scripts/common/components/TagEditor.js';
import TagLink from '../../../static/scripts/common/components/TagLink.js';
import commaOnlyList
  from '../../../static/scripts/common/i18n/commaOnlyList.js';

component TagList(
  isGenreList: boolean = false,
  tags: ?$ReadOnlyArray<AggregatedTagT>,
) {
  const $c = React.useContext(CatalystContext);
  const upvotedTags = tags ? tags.filter(tag => tag.count > 0) : null;
  const links = upvotedTags ? upvotedTags.reduce((
    accum: Array<React.MixedElement>,
    aggregatedTag,
  ) => {
    const genre = $c.stash.genre_map?.[aggregatedTag.tag.name];
    if ((genre != null) === isGenreList) {
      accum.push(
        <TagLink
          key={'tag-' + aggregatedTag.tag.name}
          tag={aggregatedTag.tag.name}
        />,
      );
    }
    return accum;
  }, []) : null;
  if (!links || !links.length) {
    return isGenreList
      ? lp('(none)', 'genre')
      : lp('(none)', 'folksonomy tag');
  }
  return commaOnlyList(links);
}

component SidebarTags(entity: TaggableEntityT) {
  const $c = React.useContext(CatalystContext);
  const aggregatedTags = $c.stash.top_tags;
  const more = Boolean($c.stash.more_tags);
  const userTags = $c.stash.user_tags;

  return (
    $c.action.name === 'tags' ? null : (
      ($c.user?.has_confirmed_email_address &&
        aggregatedTags && userTags) ? (
          <SidebarTagEditor
            aggregatedTags={aggregatedTags}
            entity={entity}
            genreMap={$c.stash.genre_map}
            more={more}
            userTags={userTags}
          />
        ) : (
          <div id="sidebar-tags">
            <h2>{lp('Tags', 'folksonomy')}</h2>

            <h3>{l('Genres')}</h3>
            <div className="genre-list">
              <p>
                <TagList isGenreList tags={aggregatedTags} />
              </p>
            </div>

            <h3>{lp('Other tags', 'folksonomy')}</h3>
            <div id="sidebar-tag-list">
              <p>
                <TagList tags={aggregatedTags} />
              </p>
            </div>

            <p>
              <EntityLink
                content={lp('See all tags', 'folksonomy')}
                entity={entity}
                subPath="tags"
              />
            </p>
          </div>
        )
    )
  );
}

export default SidebarTags;
