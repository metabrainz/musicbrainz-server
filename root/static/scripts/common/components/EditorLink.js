// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const crypto = require('crypto');
const {trim} = require('lodash');
const React = require('react');

const entityHREF = require('../utility/entityHREF');
const isolateText = require('../utility/isolateText');

function gravatar(email) {
  let hex = crypto.createHash('md5').update(trim(email).toLowerCase()).digest('hex');
  return `//gravatar.com/avatar/${hex}?d=mm`;
}

const EditorLink = ({editor, content, avatarSize, subPath}) => {
  if (!content) {
    content = editor.name;
  }

  if (!avatarSize) {
    avatarSize = 12;
  }

  let imageURL;
  if (editor.preferences.show_gravatar) {
    imageURL = gravatar(editor.email) + '&s=' + (avatarSize * 2);
  } else {
    imageURL = '//gravatar.com/avatar/placeholder?d=mm&s=' + (avatarSize * 2);
  }

  return (
    <a href={entityHREF('editor', editor.name, subPath)}>
      <img src={imageURL} height={avatarSize} width={avatarSize} className="gravatar" alt="" />
      {isolateText(content)}
    </a>
  );
};

module.exports = EditorLink;
