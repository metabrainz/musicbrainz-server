/*
 * @flow
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

const serializeObject = (obj) => {
  return Object.keys(obj).map(key => key + '=' + encodeURIComponent(obj[key])).join('&');
};

exports.addColon = (str: string) => {
  return str + ':';
};

exports.formatPercentage = (num: number, digits: number, $c: CatalystContextT) => {
  return (num || 0).toLocaleString($c.stash.current_language,
    {maximumFractionDigits: digits, minimumFractionDigits: digits, style: 'percent'});
};

exports.formatCount = (num: number, $c: CatalystContextT) => {
  return typeof num === 'number' ? num.toLocaleString($c.stash.current_language) : '';
};

exports.LinkSearchableProperty = ({
  entityType,
  searchField,
  searchValue,
  text,
}: LinkSearchablePropertyT) => {
  const params = {
    limit: '25',
    method: 'advanced',
    query: searchValue ? searchField + ':"' + searchValue + '"' : '-' + searchField + ':' + '*',
    type: entityType,
  };
  return (
    <a href={'/search?' + serializeObject(params)}>
      {text ? text : searchValue}
    </a>
  );
};
