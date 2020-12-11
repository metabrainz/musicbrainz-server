/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ENTITIES from '../../entities';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink';
import EntityLink
  from '../static/scripts/common/components/EntityLink';
import expand2text from '../static/scripts/common/i18n/expand2text';
import {formatCount} from '../statistics/utilities';

import TagLayout from './TagLayout';

type Props = {
  +$c: CatalystContextT,
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
};

function buildSection(
  props: Props,
  entityType: string,
  title: string,
  seeAllMessage: $Call<typeof N_ln, string, string>,
) {
  const tags = props.taggedEntities[entityType];

  if (!tags.count) {
    return null;
  }

  const entityUrlFragment = ENTITIES[entityType].url;
  const url = '/tag/' + encodeURIComponent(props.tag.name) +
              '/' + entityUrlFragment;

  return (
    <React.Fragment key={entityType}>
      <h2>{title}</h2>
      <ul>
        {tags.tags.map(tag => (
          <li key={tag.entity_id}>
            <DescriptiveLink entity={tag.entity} />
          </li>
        ))}
        {tags.count > tags.tags.length ? (
          <li key="see-all">
            <em>
              <a href={url}>
                {expand2text(
                  seeAllMessage(tags.count),
                  {num: formatCount(props.$c, tags.count)},
                )}
              </a>
            </em>
          </li>
        ) : null}
      </ul>
    </React.Fragment>
  );
}

const TagIndex = (props: Props): React.Element<typeof TagLayout> => {
  const genre = props.tag.genre;
  return (
    <TagLayout $c={props.$c} page="" tag={props.tag}>
      {genre ? (
        <>
          <h2>{l('Genre')}</h2>
          <p>
            {exp.l('This tag is associated with the genre {genre}.',
                   {genre: <EntityLink entity={genre} />})}
          </p>
        </>
      ) : null}
      {/*
        * The below use N_ln so languages with non-Germanic pluralization
        * rules (i.e., any that make number distinctions above the
        * threshold where we'll actually show the string) can translate
        * properly. However, the strings are the same in English because
        * we do not make a distinction other than for 1, which will never
        * show in this case.
      */}
      {buildSection(props, 'area', l('Areas'), N_ln(
        'See all {num} areas',
        'See all {num} areas',
      ))}
      {buildSection(props, 'artist', l('Artists'), N_ln(
        'See all {num} artists',
        'See all {num} artists',
      ))}
      {buildSection(props, 'event', l('Events'), N_ln(
        'See all {num} events',
        'See all {num} events',
      ))}
      {buildSection(props, 'instrument', l('Instruments'), N_ln(
        'See all {num} instruments',
        'See all {num} instruments',
      ))}
      {buildSection(props, 'label', l('Labels'), N_ln(
        'See all {num} labels',
        'See all {num} labels',
      ))}
      {buildSection(props, 'place', l('Places'), N_ln(
        'See all {num} places',
        'See all {num} places',
      ))}
      {buildSection(props, 'release_group', l('Release Groups'), N_ln(
        'See all {num} release groups',
        'See all {num} release groups',
      ))}
      {buildSection(props, 'release', l('Releases'), N_ln(
        'See all {num} releases',
        'See all {num} releases',
      ))}
      {buildSection(props, 'recording', l('Recordings'), N_ln(
        'See all {num} recordings',
        'See all {num} recordings',
      ))}
      {buildSection(props, 'series', l('Series'), N_ln(
        'See all {num} series',
        'See all {num} series',
      ))}
      {buildSection(props, 'work', l('Works'), N_ln(
        'See all {num} works',
        'See all {num} works',
      ))}
    </TagLayout>
  );
};

export default TagIndex;
