/*
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');

const serializeObject = (obj) => {
  return Object.keys(obj).map(key => key + '=' + encodeURIComponent(obj[key])).join('&');
};

exports.addColon = (str) => {
  return str + ':';
};

exports.formatPercentage = (num, digits) => {
  return (num || 0).toLocaleString($c.stash.current_language,
    {maximumFractionDigits: digits, minimumFractionDigits: digits, style: 'percent'});
};

exports.formatCount = (num) => {
  return typeof num === 'number' ? num.toLocaleString($c.stash.current_language) : '';
};

exports.LinkSearchableProperty = ({
  searchField,
  searchValue,
  entityType,
  text,
}) => {
  const params = {
    limit: 25,
    method: 'advanced',
    query: searchField + ':"' + searchValue + '"',
    type: entityType,
  };
  return (
    <a href={'/search?' + serializeObject(params)}>
      {text ? text : searchValue}
    </a>
  );
};
