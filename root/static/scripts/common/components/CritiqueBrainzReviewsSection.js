/*
 * @flow
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {minimalEntity} from '../../../../utility/hydrate.js';
import entityHref from '../utility/entityHref.js';

import CritiqueBrainzLinks from './CritiqueBrainzLinks.js';
import CritiqueBrainzReview from './CritiqueBrainzReview.js';

type Props = {
  +entity: ReviewableT,
};

type State = {
  mostPopularReview: CritiqueBrainzReviewT | null,
  mostRecentReview: CritiqueBrainzReviewT | null,
  reviewCount: number | null,
};

class CritiqueBrainzReviewsSection extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      mostPopularReview: null,
      mostRecentReview: null,
      reviewCount: null,
    };
  }

  componentDidMount() {
    const $ = require('jquery');
    $.get(entityHref(this.props.entity, '/critiquebrainz-reviews'), data => {
      this.setState(data);
    });
  }

  render(): React.MixedElement | null {
    const {mostPopularReview, mostRecentReview, reviewCount} = this.state;

    return (
      <>
        <h2>{l('Reviews')}</h2>

        <CritiqueBrainzLinks
          entity={this.props.entity}
          reviewCount={reviewCount}
        />
        <div id="critiquebrainz-reviews">
          {mostRecentReview ? (
            <CritiqueBrainzReview
              review={mostRecentReview}
              title={l('Most Recent')}
            />
          ) : null}
          {mostPopularReview && mostRecentReview &&
            mostPopularReview.id !== mostRecentReview.id ? (
              <CritiqueBrainzReview
                review={mostPopularReview}
                title={l('Most Popular')}
              />
            ) : null}
        </div>
      </>
    );
  }
}

export default (hydrate<Props>(
  'div.critiquebrainz-reviews-section',
  CritiqueBrainzReviewsSection,
  minimalEntity,
): React.AbstractComponent<Props, void>);
