// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015—2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

const {l} = require('../i18n');

function commaList(items, props = {}) {
  let count = items.length;

  if (count <= 1) {
    return items[0] || '';
  }

  let output = l('{almost_last_list_item} and {last_list_item}', {
    __react: props.react,
    almost_last_list_item: items[count - 2],
    last_list_item: items[count - 1],
  });

  items = items.slice(0, -2).reverse();
  count -= 2;

  for (let i = 0; i < count; i++) {
    output = l('{list_item}, {rest}', {
      __react: props.react,
      list_item: items[i],
      rest: output,
    });
  }

  return props.react ? <frag>{output}</frag> : output;
}

module.exports = commaList;
