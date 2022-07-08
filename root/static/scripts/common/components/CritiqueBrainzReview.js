/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import formatUserDate from '../../../../utility/formatUserDate';
import DBDefs from '../DBDefs-client.mjs';

import Collapsible from './Collapsible';

export type CritiqueBrainzUserT = {
  +id: string,
  +name: string,
};

export type CritiqueBrainzReviewT = {
  +author: CritiqueBrainzUserT,
  +body: string,
  +created: string,
  +id: string,
};

type Props = {
  +review: CritiqueBrainzReviewT,
  +title: string,
};

const authorHref = author => (
  DBDefs.CRITIQUEBRAINZ_SERVER + '/user/' + author.id
);

const reviewHref = review => (
  DBDefs.CRITIQUEBRAINZ_SERVER + '/review/' + review.id
);

const CritiqueBrainzReview = ({review, title}: Props) => (
  <>
    <h3>{title}</h3>
    <p className="review-metadata">
      <SanitizedCatalystContext.Consumer>
        {$c => exp.l('{review_link|Review} by {author} on {date}', {
          author: (
            <a href={authorHref(review.author)} key="author">
              {review.author.name}
            </a>
          ),
          date: formatUserDate($c, review.created, {dateOnly: true}),
          review_link: {href: reviewHref(review), key: 'review_link'},
        })}
      </SanitizedCatalystContext.Consumer>
    </p>
    <Collapsible className="review" html={review.body} />
  </>
);

export default (hydrate<Props>(
  'div.critiquebrainz-review',
  CritiqueBrainzReview,
): React.AbstractComponent<Props, void>);
