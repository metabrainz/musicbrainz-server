// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const crypto = require('crypto');
const {trim} = require('lodash');
const React = require('react');

function gravatar(email) {
  let hex = crypto.createHash('md5').update(trim(email).toLowerCase()).digest('hex');
  return `//gravatar.com/avatar/${hex}?d=mm`;
}

const EditorLink = ({editor, size}) => {
  size = size || 12;

  let editorName = editor.name;
  let imageURL;

  if (editor.preferences.show_gravatar) {
    imageURL = gravatar(editor.email) + '&amp;s=' + (size * 2);
  } else {
    imageURL = '//gravatar.com/avatar/placeholder?d=mm&amp;s=' + (size * 2);
  }

  return (
    <a href={`/user/${editorName}`}>
      <img src={imageURL} height={size} width={size} className="gravatar" />
      <bdi>{editorName}</bdi>
    </a>
  );
};

module.exports = EditorLink;
