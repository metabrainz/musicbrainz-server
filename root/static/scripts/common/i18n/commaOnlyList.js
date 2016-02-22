// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015—2016 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');

const {l} = require('../i18n');

function commaOnlyList(items, props = {}) {
  if (!items.length) {
    return '';
  }

  let output = l('{last_list_item}', {
    __react: props.react,
    last_list_item: items.pop(),
  });

  items.reverse();

  for (let i = 0; i < items.length; i++) {
    output = l('{commas_only_list_item}, {rest}', {
      __react: props.react,
      commas_only_list_item: items[i],
      rest: output,
    });
  }

  return props.react ? <frag>{output}</frag> : output;
}

module.exports = commaOnlyList;
