/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../../../../context';
import formatUserDate from '../../../../utility/formatUserDate';
import hydrate from '../../../../utility/hydrate';
import * as DBDefs from '../DBDefs-client';

import Collapsible from './Collapsible';

type Props = {|
  +$c: CatalystContextT | SanitizedCatalystContextT,
  +review: CritiqueBrainzReviewT,
  +title: string,
|};

const authorHref = author => (
  DBDefs.CRITIQUEBRAINZ_SERVER + '/user/' + author.id
);

const reviewHref = review => (
  DBDefs.CRITIQUEBRAINZ_SERVER + '/review/' + review.id
);

const CritiqueBrainzReview = ({$c, review, title}: Props) => (
  <>
    <h3>{title}</h3>
    <p className="review-metadata">
      {exp.l('{review_link|Review} by {author} on {date}', {
        author: (
          <a href={authorHref(review.author)} key="author">
            {review.author.name}
          </a>
        ),
        date: formatUserDate($c.user, review.created, {dateOnly: true}),
        review_link: {href: reviewHref(review), key: 'review_link'},
      })}
    </p>
    <Collapsible className="review" html={review.body} />
  </>
);

export default withCatalystContext(hydrate(
  'div.critiquebrainz-review',
  CritiqueBrainzReview,
));
