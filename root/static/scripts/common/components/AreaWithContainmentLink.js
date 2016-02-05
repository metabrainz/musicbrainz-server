// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015–2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

const EntityLink = require('./EntityLink');
const commaOnlyList = require('../../common/i18n/commaOnlyList');

const AreaWithContainmentLink = ({area, ...props}) => {
  let links = [<EntityLink entity={area} key={0} {...props} />];
  let containment = area.containment;

  for (let i = 0; i < containment.length; i++) {
    links.push(<EntityLink entity={containment[i]} key={i + 1} />);
  }

  return commaOnlyList(links, {react: true});
};

module.exports = AreaWithContainmentLink;
