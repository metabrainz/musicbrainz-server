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
  +entity: RatableT,
  +privateRatingCount: number,
  +publicRatings: $ReadOnlyArray<RatingT>,
};

const Ratings = ({
  entity,
  privateRatingCount,
  publicRatings,
}: Props): React.MixedElement => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);
  const hasRatings = publicRatings.length || privateRatingCount > 0;

  return (
    <LayoutComponent
      entity={entity}
      page="ratings"
      title={l('Ratings')}
    >
      <h2>{l('Ratings')}</h2>

      {hasRatings ? (
        <>
          {publicRatings.length ? (
            <ul>
              {publicRatings.map(rating => (
                <li key={rating.editor.id}>
                  <StaticRatingStars rating={rating.rating} />
                  {' - '}
                  <EditorLink editor={rating.editor} />
                </li>
              ))}
            </ul>
          ) : null}
          {privateRatingCount > 0 ? (
            <p>
              {exp.ln(
                '{count} private rating not listed.',
                '{count} private ratings not listed.',
                privateRatingCount,
                {count: privateRatingCount},
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
