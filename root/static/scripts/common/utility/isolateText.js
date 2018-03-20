/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');

function isolateText(content) {
  if (content) {
    return <bdi>{content}</bdi>;
  }
  return '';
}

module.exports = isolateText;
