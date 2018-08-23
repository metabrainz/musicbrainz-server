// @flow
// Copyright (C) 2017 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

import RatingStars from '../../../components/RatingStars';
const {l} = require('../../../static/scripts/common/i18n');
const EntityLink = require('../../../static/scripts/common/components/EntityLink');

type Props = {|
  +entity: RatableT,
  +heading?: string,
|};

const SidebarRating = ({entity, heading}: Props) => (
  <>
    <h2 className="rating">{heading || l('Rating')}</h2>
    <p>
      <RatingStars entity={entity} />
      {entity.rating_count > 0 ?
        <>
          {' ('}
          <EntityLink
            entity={entity}
            subPath="ratings"
            content={l('see all ratings')}
          />
          {')'}
        </>
      : null}
    </p>
  </>
);

module.exports = SidebarRating;
