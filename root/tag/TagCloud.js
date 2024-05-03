/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import Layout from '../layout/index.js';
import TagLink from '../static/scripts/common/components/TagLink.js';
import {sortByNumber} from '../static/scripts/common/utility/arrays.js';
import {formatCount} from '../statistics/utilities.js';
import loopParity from '../utility/loopParity.js';

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

function generateTagCloud(
  $c: CatalystContextT,
  tags: $ReadOnlyArray<AggregatedTagT>,
  maxCount: number,
) {
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

function generateTagList(
  $c: CatalystContextT,
  tags: $ReadOnlyArray<AggregatedTagT>,
) {
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

component TagCloud(
  genreMaxCount: number,
  genres: $ReadOnlyArray<AggregatedTagT>,
  showList: boolean = false,
  tagMaxCount: number,
  tags: $ReadOnlyArray<AggregatedTagT>,
) {
  const $c = React.useContext(CatalystContext);
  return (
    <Layout fullWidth title={lp('Tags', 'folksonomy')}>
      <div id="content">
        <h1>{lp('Tags', 'folksonomy')}</h1>
        <p>
          {l(
            'These are the most used genres and other tags in the database.',
          )}
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

        ) : lp('No genre tags have been used yet.', 'folksonomy')}

        <h2>{l('Other tags')}</h2>
        {tags.length ? (
          showList
            ? generateTagList($c, tags)
            : generateTagCloud($c, tags, tagMaxCount)
        ) : lp('No non-genre tags have been used yet.', 'folksonomy')}
      </div>
    </Layout>
  );
}

export default TagCloud;
