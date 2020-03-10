/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {type AccountLayoutUserT} from '../components/UserAccountLayout';
import {ENTITIES} from '../static/scripts/common/constants';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink';
import TagLink, {UserTagLink}
  from '../static/scripts/common/components/TagLink';
import expand2text from '../static/scripts/common/i18n/expand2text';
import {formatCount} from '../statistics/utilities';

type Props = {
  +$c: CatalystContextT,
  +showDownvoted?: boolean,
  +tag: TagT,
  +taggedEntities: {
    +[entityType: string]: {
      +count: number,
      +tags: $ReadOnlyArray<{
        +count: number,
        +entity: CoreEntityT,
        +entity_id: number,
      }>,
    },
  },
  +tagInUse?: boolean,
  +user?: AccountLayoutUserT | EditorT,
};

function buildTagListSection(
  props: Props,
  entityType: string,
  title: string,
  seeAllMessage: $Call<typeof N_ln, string, string>,
) {
  const tags = props.taggedEntities[entityType];

  if (!tags.count) {
    return null;
  }

  const url = ENTITIES[entityType].url;
  const user = props.user;

  return (
    <React.Fragment key={entityType}>
      <h3>{title}</h3>
      <ul>
        {tags.tags.map(tag => (
          <li key={tag.entity_id}>
            <DescriptiveLink entity={tag.entity} />
          </li>
        ))}
        {tags.count > tags.tags.length ? (
          <li key="see-all">
            <em>
              {user ? (
                <UserTagLink
                  content={expand2text(
                    seeAllMessage(tags.count),
                    {num: formatCount(props.$c, tags.count)},
                  )}
                  subPath={url}
                  tag={props.tag.name}
                  username={user.name}
                />
              ) : (
                <TagLink
                  content={expand2text(
                    seeAllMessage(tags.count),
                    {num: formatCount(props.$c, tags.count)},
                  )}
                  subPath={url}
                  tag={props.tag.name}
                />
              )}
            </em>
          </li>
        ) : null}
      </ul>
    </React.Fragment>
  );
}

const TagList = (props: Props): React.Element<typeof React.Fragment> => (
  <>
    {/*
      * The below use N_ln so languages with non-Germanic pluralization
      * rules (i.e., any that make number distinctions above the
      * threshold where we'll actually show the string) can translate
      * properly. However, the strings are the same in English because
      * we do not make a distinction other than for 1, which will never
      * show in this case.
    */}
    {buildTagListSection(props, 'area', l('Areas'), N_ln(
      'See all {num} areas',
      'See all {num} areas',
    ))}
    {buildTagListSection(props, 'artist', l('Artists'), N_ln(
      'See all {num} artists',
      'See all {num} artists',
    ))}
    {buildTagListSection(props, 'event', l('Events'), N_ln(
      'See all {num} events',
      'See all {num} events',
    ))}
    {buildTagListSection(props, 'instrument', l('Instruments'), N_ln(
      'See all {num} instruments',
      'See all {num} instruments',
    ))}
    {buildTagListSection(props, 'label', l('Labels'), N_ln(
      'See all {num} labels',
      'See all {num} labels',
    ))}
    {buildTagListSection(props, 'place', l('Places'), N_ln(
      'See all {num} places',
      'See all {num} places',
    ))}
    {buildTagListSection(props, 'release_group', l('Release Groups'), N_ln(
      'See all {num} release groups',
      'See all {num} release groups',
    ))}
    {buildTagListSection(props, 'release', l('Releases'), N_ln(
      'See all {num} releases',
      'See all {num} releases',
    ))}
    {buildTagListSection(props, 'recording', l('Recordings'), N_ln(
      'See all {num} recordings',
      'See all {num} recordings',
    ))}
    {buildTagListSection(props, 'series', l('Series'), N_ln(
      'See all {num} series',
      'See all {num} series',
    ))}
    {buildTagListSection(props, 'work', l('Works'), N_ln(
      'See all {num} works',
      'See all {num} works',
    ))}
  </>
);

export default TagList;
