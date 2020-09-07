/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

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
  +$c: CatalystContextT,
  +aggregatedTags?: $ReadOnlyArray<AggregatedTagT> | void,
  +entity: CoreEntityT,
  +more: boolean,
  +userTags?: $ReadOnlyArray<UserTagT> | void,
};

const TagList = ({
  isGenreList = false,
  tags,
}: TagListProps) => {
  const links = tags ? tags.reduce((accum, t) => {
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
  $c,
  aggregatedTags,
  entity,
  more,
  userTags,
}: SidebarTagsProps): React.Element<typeof React.Fragment> | null => (
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

export default SidebarTags;
