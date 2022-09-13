/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DBDefs from '../DBDefs-client.mjs';
import {minimalEntity} from '../../../../utility/hydrate.js';
import entityHref from '../utility/entityHref.js';

import EntityLink from './EntityLink.js';

const seeReviewsHref = (entity: ReviewableT) => {
  const reviewUrlEntity = entity.entityType === 'release_group'
    ? 'release-group'
    : entity.entityType;
  return (
    DBDefs.CRITIQUEBRAINZ_SERVER +
    `/${reviewUrlEntity}/` +
    entity.gid
  );
};

const writeReviewLink = (entity: ReviewableT) => (
  DBDefs.CRITIQUEBRAINZ_SERVER +
  `/review/write?${entity.entityType}=` +
  entity.gid
);

type Props = {
  +entity: ReviewableT,
  +reviewCount?: number | null,
};

type State = {
  reviewCount: number | null,
};

class CritiqueBrainzLinks extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      reviewCount: props.reviewCount || null,
    };
  }

  componentDidMount() {
    if (!this.state.reviewCount) {
      const $ = require('jquery');
      $.get(
        entityHref(this.props.entity, '/critiquebrainz-review-count'),
        data => {
          this.setState(data);
        },
      );
    }
  }

  render(): React.MixedElement | string {
    const {reviewCount} = this.state;

    if (reviewCount == null) {
      return l('An error occurred when loading reviews.');
    }
    if (reviewCount === 0) {
      return exp.l(
        `No one has reviewed {entity} yet.
        Be the first to {write_link|write a review}.`,
        {
          entity: <EntityLink entity={this.props.entity} />,
          write_link: writeReviewLink(this.props.entity),
        },
      );
    }
    return exp.ln(
      `There’s {reviews_link|{review_count} review} on CritiqueBrainz.
      You can also {write_link|write your own}.`,
      `There are {reviews_link|{review_count} reviews} on CritiqueBrainz.
      You can also {write_link|write your own}.`,
      reviewCount,
      {
        review_count: reviewCount,
        reviews_link: seeReviewsHref(this.props.entity),
        write_link: writeReviewLink(this.props.entity),
      },
    );
  }
}

export default (hydrate<Props>(
  'div.critiquebrainz-links',
  CritiqueBrainzLinks,
  minimalEntity,
): React.AbstractComponent<Props, void>);
