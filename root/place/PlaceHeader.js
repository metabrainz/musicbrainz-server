/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const {l} = require('../static/scripts/common/i18n');
const {lp_attributes} = require('../static/scripts/common/i18n/attributes');
const EntityHeader = require('../components/EntityHeader');

type Props = {|
  page: string,
  place: PlaceT,
|};

const PlaceHeader = ({place, page}: Props) => (
  <EntityHeader
    entity={place}
    headerClass="placeheader"
    page={page}
    subHeading={place.typeName ? lp_attributes(place.typeName, 'place_type') : l('Place')}
  />
);

module.exports = PlaceHeader;
