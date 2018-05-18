/*
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015–2016 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');

const EntityLink = require('./EntityLink');
const commaOnlyList = require('../../common/i18n/commaOnlyList');

const makeContainmentLink = (x, i) => (
  <EntityLink entity={x} key={i + 1} />
);

const AreaWithContainmentLink = ({area, ...props}) => {
  const areaLink = <EntityLink entity={area} key={0} {...props} />;

  return area.containment ? commaOnlyList(
    [areaLink].concat(area.containment.map(makeContainmentLink)),
    {react: true},
  ) : areaLink;
};

module.exports = AreaWithContainmentLink;
