// @flow
// Copyright (C) 2013 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

const {l, ln} = require('../static/scripts/common/i18n');

const ratingTooltip = (rating: number) => (
  rating === 0
    ? l('Remove your rating')
    : ln('Rate: {rating} star', 'Rate: {rating} stars', rating, {rating})
);

module.exports = ratingTooltip;
