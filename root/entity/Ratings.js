/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import chooseLayoutComponent from '../utility/chooseLayoutComponent.js';
import * as manifest from '../static/manifest.mjs';
import {ENTITIES} from '../static/scripts/common/constants.js';
import CritiqueBrainzReviewsSection
  from '../static/scripts/common/components/CritiqueBrainzReviewsSection.js';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import {
  StaticRatingStars,
} from '../static/scripts/common/components/RatingStars.js';

type Props = {
  +entity: RatableT | ReviewableT,
  +privateRatingCount: number,
  +publicRatings: $ReadOnlyArray<RatingT>,
};

const Ratings = ({
  entity,
  privateRatingCount,
  publicRatings,
}: Props): React.MixedElement => {
  const entityType = entity.entityType;
  const entityProperties = ENTITIES[entity.entityType];
  const LayoutComponent = chooseLayoutComponent(entityType);
  const hasRatings = publicRatings.length || privateRatingCount > 0;

  return (
    <LayoutComponent
      entity={entity}
      page="ratings"
      title={l('Reviews')}
    >
      {entityProperties.ratings ? (
        <>
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
              {/* $FlowIgnore[prop-missing] we know it has ratings */}
              <StaticRatingStars rating={entity.rating} />
            </>
          ) : (
            <p>
              {exp.l('{link} has no ratings.',
                     {link: <EntityLink entity={entity} />})}
            </p>
          )}
        </>
      ) : null}

      {entityProperties.reviews ? (
        <CritiqueBrainzReviewsSection entity={entity} />
      ) : null}
      {manifest.js('reviews', {async: 'async'})}
    </LayoutComponent>
  );
};

export default Ratings;
