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
import EntityLink from '../../../static/scripts/common/components/EntityLink';
import {SidebarTagEditor}
  from '../../../static/scripts/common/components/TagEditor';
import TagLink from '../../../static/scripts/common/components/TagLink';
import commaOnlyList from '../../../static/scripts/common/i18n/commaOnlyList';

type TagListProps = {
  +entity: CoreEntityT,
  +isGenreList?: boolean,
  +tags: ?$ReadOnlyArray<AggregatedTagT>,
};

type SidebarTagsProps = {
  +entity: CoreEntityT,
};

const TagList = ({
  isGenreList = false,
  tags,
}: TagListProps) => {
  const upvotedTags = tags ? tags.filter(tag => tag.count > 0) : null;
  const links = upvotedTags ? upvotedTags.reduce((accum, t) => {
    if (Boolean(t.tag.genre) === isGenreList) {
      accum.push(<TagLink key={'tag-' + t.tag.name} tag={t.tag.name} />);
    }
    return accum;
  }, []) : null;
  if (!links || !links.length) {
    return isGenreList ? lp('(none)', 'genre') : lp('(none)', 'tag');
  }
  return commaOnlyList(links);
};

const SidebarTags = ({
  entity,
}: SidebarTagsProps): React.Element<typeof React.Fragment> | null => {
  const $c = React.useContext(CatalystContext);
  const aggregatedTags = $c.stash.top_tags;
  const more = Boolean($c.stash.more_tags);
  const userTags = $c.stash.user_tags;

  return (
    $c.action.name === 'tags' ? null : (
      <>
        {($c.user?.has_confirmed_email_address &&
          aggregatedTags && userTags) ? (
            <SidebarTagEditor
              $c={$c}
              aggregatedTags={aggregatedTags}
              entity={entity}
              genreMap={$c.stash.genre_map}
              more={more}
              userTags={userTags}
            />
          ) : (
            <div id="sidebar-tags">
              <h2>{l('Genres')}</h2>
              <div className="genre-list">
                <p>
                  <TagList
                    entity={entity}
                    isGenreList
                    tags={aggregatedTags}
                  />
                </p>
              </div>

              <h2>{l('Other tags')}</h2>
              <div id="sidebar-tag-list">
                <p>
                  <TagList
                    entity={entity}
                    tags={aggregatedTags}
                  />
                </p>
              </div>

              <p>
                <EntityLink
                  content={l('See all tags')}
                  entity={entity}
                  subPath="tags"
                />
              </p>
            </div>
          )}
      </>
    )
  );
};

export default SidebarTags;
