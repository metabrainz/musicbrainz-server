/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import CritiqueBrainzLinks from '../components/CritiqueBrainzLinks.js';
import * as manifest from '../static/manifest.mjs';
import CritiqueBrainzReview
  from '../static/scripts/common/components/CritiqueBrainzReview.js';
import EditorLink from '../static/scripts/common/components/EditorLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import {
  StaticRatingStars,
} from '../static/scripts/common/components/RatingStars.js';
import {ENTITIES} from '../static/scripts/common/constants.js';
import chooseLayoutComponent from '../utility/chooseLayoutComponent.js';

type Props = {
  +entity: RatableT | ReviewableT,
  +mostPopularReview: CritiqueBrainzReviewT,
  +mostRecentReview: CritiqueBrainzReviewT,
  +privateRatingCount: number,
  +publicRatings: $ReadOnlyArray<RatingT>,
};

const Ratings = ({
  entity,
  mostPopularReview,
  mostRecentReview,
  privateRatingCount,
  publicRatings,
}: Props): React$MixedElement => {
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
        <>
          <h2>{l('Reviews')}</h2>

          <CritiqueBrainzLinks entity={entity} />
          <div id="critiquebrainz-reviews">
            {mostRecentReview ? (
              <CritiqueBrainzReview
                review={mostRecentReview}
                title={l('Most Recent')}
              />
            ) : null}
            {mostPopularReview &&
              mostPopularReview.id !== mostRecentReview.id ? (
                <CritiqueBrainzReview
                  review={mostPopularReview}
                  title={l('Most Popular')}
                />
              ) : null}
          </div>
        </>
      ) : null}
      {manifest.js('reviews')}
    </LayoutComponent>
  );
};

export default Ratings;
