/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {type AccountLayoutUserT} from '../../components/UserAccountLayout';
import EditorLink from '../../static/scripts/common/components/EditorLink';
import TagLink from '../../static/scripts/common/components/TagLink';
import expand2react from '../../static/scripts/common/i18n/expand2react';
import expand2text from '../../static/scripts/common/i18n/expand2text';
import {headingsText} from '../../tag/EntityList';

type Props = {
  +entityType?: string,
  +showDownvoted: boolean,
  +tag: TagT,
  +user: AccountLayoutUserT,
};

const noDownvotesText = {
  area: N_l('{user} has not voted against any “{tag}” tags for areas.'),
  artist: N_l('{user} has not voted against any “{tag}” tags for artists.'),
  event: N_l('{user} has not voted against any “{tag}” tags for events.'),
  instrument: N_l(
    '{user} has not voted against any “{tag}” tags for instruments.',
  ),
  label: N_l('{user} has not voted against any “{tag}” tags for labels.'),
  place: N_l('{user} has not voted against any “{tag}” tags for places.'),
  recording: N_l(
    '{user} has not voted against any “{tag}” tags for recordings.',
  ),
  release: N_l('{user} has not voted against any “{tag}” tags for releases.'),
  release_group: N_l(
    '{user} has not voted against any “{tag}” tags for release groups.',
  ),
  series: N_l('{user} has not voted against any “{tag}” tags for series.'),
  work: N_l('{user} has not voted against any “{tag}” tags for works.'),
};

const noTagsText = {
  area: N_l('{user} has not tagged any areas with “{tag}”.'),
  artist: N_l('{user} has not tagged any artists with “{tag}”.'),
  event: N_l('{user} has not tagged any events with “{tag}”.'),
  instrument: N_l('{user} has not tagged any instruments with “{tag}”.'),
  label: N_l('{user} has not tagged any labels with “{tag}”.'),
  place: N_l('{user} has not tagged any places with “{tag}”.'),
  recording: N_l('{user} has not tagged any recordings with “{tag}”.'),
  release: N_l('{user} has not tagged any releases with “{tag}”.'),
  release_group: N_l(
    '{user} has not tagged any release groups with “{tag}”.',
  ),
  series: N_l('{user} has not tagged any series with “{tag}”.'),
  work: N_l('{user} has not tagged any works with “{tag}”.'),
};

const UserHasNotUsedTag = ({
  entityType,
  showDownvoted,
  tag,
  user,
}: Props): React.Element<typeof React.Fragment | 'p'> => (
  nonEmpty(entityType) ? (
    <>
      <h3>
        {expand2text(
          headingsText[entityType](0),
          {num: 0},
        )}
      </h3>
      <p>
        {expand2react(
          showDownvoted
            ? noDownvotesText[entityType]()
            : noTagsText[entityType](),
          {
            tag: <TagLink tag={tag.name} />,
            user: <EditorLink editor={user} />,
          },
        )}
      </p>
    </>
  ) : (
    <p>
      {showDownvoted ? (
        exp.l('{user} has not voted against any “{tag}” tags.',
              {
                tag: <TagLink tag={tag.name} />,
                user: <EditorLink editor={user} />,
              })
      ) : (
        exp.l('{user} has not tagged anything with “{tag}”.',
              {
                tag: <TagLink tag={tag.name} />,
                user: <EditorLink editor={user} />,
              })
      )}
    </p>
  )
);

export default UserHasNotUsedTag;
