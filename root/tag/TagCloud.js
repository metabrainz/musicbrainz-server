/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import TagLink from '../static/scripts/common/components/TagLink';
import {sortByNumber} from '../static/scripts/common/utility/arrays';
import {formatCount} from '../statistics/utilities';
import loopParity from '../utility/loopParity';

type Props = {
  +$c: CatalystContextT,
  +genreMaxCount: number,
  +genres: $ReadOnlyArray<AggregatedTagT>,
  +moodMaxCount: number,
  +moods: $ReadOnlyArray<AggregatedTagT>,
  +showList?: boolean,
  +tagMaxCount: number,
  +tags: $ReadOnlyArray<AggregatedTagT>,
};

function getTagSize(count: number, tagMaxCount: number) {
  const percent = count / tagMaxCount * 100;
  if (percent < 1) {
    return 'tag1';
  }
  if (percent < 3) {
    return 'tag2';
  }
  if (percent < 6) {
    return 'tag3';
  }
  if (percent < 15) {
    return 'tag4';
  }
  if (percent < 25) {
    return 'tag5';
  }
  if (percent < 50) {
    return 'tag6';
  }
  return 'tag7';
}

function generateTagCloud($c, tags, maxCount) {
  return (
    <ul className="tag-cloud">
      {tags.map(({count, tag}) => (
        <li
          className={getTagSize(count, maxCount)}
          key={tag.name}
          title={texp.l(
            "'{tag}' has been used {num} times",
            {num: formatCount($c, count), tag: tag.name},
          )}
        >
          <TagLink tag={tag.name} />
          {' '}
        </li>
      ))}
    </ul>
  );
}

function generateTagList($c, tags) {
  const sortedTags = sortByNumber(tags, tag => -tag.count);
  return (
    <ul className="tag-list top-tag-list">
      {sortedTags.map((tag, index) => (
        <li className={loopParity(index)} key={tag.tag.id}>
          <TagLink tag={tag.tag.name} />
          <span className="tag-vote-buttons">
            <span className="tag-count">{formatCount($c, tag.count)}</span>
          </span>
        </li>
      ))}
    </ul>
  );
}

const TagCloud = ({
  $c,
  genreMaxCount,
  genres,
  moodMaxCount,
  moods,
  showList = false,
  tagMaxCount,
  tags,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Tags')}>
    <div id="content">
      <h1>{l('Tags')}</h1>
      <p>
        {l(`These are the most used genres, moods
            and other tags in the database.`)}
        {' '}
        {showList ? (
          <a href="/tags?show_list=0">{l('Show as a cloud instead.')}</a>
        ) : (
          <a href="/tags?show_list=1">{l('Show as a list instead.')}</a>
        )}
      </p>

      <h2>{l('Genres')}</h2>
      {genres.length ? (
        showList
          ? generateTagList($c, genres)
          : generateTagCloud($c, genres, genreMaxCount)

      ) : l('No genre tags have been used yet.')}

      <h2>{l('Moods')}</h2>
      {moods.length ? (
        showList
          ? generateTagList($c, moods)
          : generateTagCloud($c, moods, moodMaxCount)

      ) : l('No mood tags have been used yet.')}

      <h2>{l('Other tags')}</h2>
      {tags.length ? (
        showList
          ? generateTagList($c, tags)
          : generateTagCloud($c, tags, tagMaxCount)
      ) : l('No other tags have been used yet.')}
    </div>
  </Layout>
);

export default TagCloud;
