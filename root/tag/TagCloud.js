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
import {formatCount} from '../statistics/utilities';

type Props = {
  +$c: CatalystContextT,
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

const TagCloud = ({
  $c,
  tagMaxCount,
  tags,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Tags')}>
    <div id="content">
      <h1>{l('Tags')}</h1>
      <p>
        {tags.length ? (
          <ul className="tag-cloud">
            {tags.map(({count, tag}) => (
              <li
                className={getTagSize(count, tagMaxCount)}
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
        ) : l('The database has no tags.')}
      </p>
    </div>
  </Layout>
);

export default TagCloud;
