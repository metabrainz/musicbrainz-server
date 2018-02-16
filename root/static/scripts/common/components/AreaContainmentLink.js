/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');

const EntityLink = require('./EntityLink');
const commaOnlyList = require('../../common/i18n/commaOnlyList');

const makeLink = (x, i) => <EntityLink entity={x} key={i} />;

const AreaContainmentLink = ({area, ...props}) => (
  commaOnlyList(area.containment.map(makeLink), {react: true})
);

module.exports = AreaContainmentLink;
