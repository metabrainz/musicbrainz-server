// @flow
// Copyright (C) 2017 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

const Frag = require('../../../components/Frag');
const RatingStars = require('../../../components/RatingStars');
const {l} = require('../../../static/scripts/common/i18n');
const EntityLink = require('../../../static/scripts/common/components/EntityLink');

type Props = {
  entity: RatableT;
  heading?: string;
};

const SidebarRating = ({entity, heading}: Props) => (
  <Frag>
    <h2 className="rating">{heading || l('Rating')}</h2>
    <p>
      <RatingStars entity={entity} />
      {entity.rating_count > 0 ?
        <Frag>
          {' ('}
          <EntityLink
            entity={entity}
            subPath="ratings"
            content={l('see all ratings')}
          />
          {')'}
        </Frag>
      : null}
    </p>
  </Frag>
);

module.exports = SidebarRating;
