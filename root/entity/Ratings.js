/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {StaticRatingStars} from '../components/RatingStars';
import chooseLayoutComponent from '../utility/chooseLayoutComponent';
import EditorLink from '../static/scripts/common/components/EditorLink';
import EntityLink from '../static/scripts/common/components/EntityLink';

type Props = {
  +$c: CatalystContextT,
  +entity: RatableT,
  +ratings: $ReadOnlyArray<RatingT>,
};

const Ratings = ({
  $c,
  entity,
  ratings,
}: Props): React.MixedElement => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);
  let privateRatingAmount = 0;

  return (
    <LayoutComponent
      $c={$c}
      entity={entity}
      page="ratings"
      title={l('Ratings')}
    >
      <h2>{l('Ratings')}</h2>

      {ratings.length ? (
        <>
          <ul>
            {ratings.map(rating => {
              if (!rating.editor.preferences.public_ratings) {
                privateRatingAmount++;
                return null;
              }
              return (
                <li key={rating.editor.id}>
                  <StaticRatingStars rating={rating.rating} />
                  {' - '}
                  <EditorLink editor={rating.editor} />
                </li>
              );
            })}
          </ul>
          {privateRatingAmount > 0 ? (
            <p>
              {exp.ln(
                '{count} private rating not listed.',
                '{count} private ratings not listed.',
                privateRatingAmount,
                {count: privateRatingAmount},
              )}
            </p>
          ) : null}
          {l('Average rating:')}
          {' '}
          <StaticRatingStars rating={entity.rating} />
        </>
      ) : (
        <p>
          {exp.l('{link} has no ratings.',
                 {link: <EntityLink entity={entity} />})}
        </p>
      )}
    </LayoutComponent>
  );
};

export default Ratings;
