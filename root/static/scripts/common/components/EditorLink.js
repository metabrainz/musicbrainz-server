// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const {trim} = require('lodash');
const React = require('react');

const entityHref = require('../utility/entityHref');
const isolateText = require('../utility/isolateText');

const EditorLink = ({editor, content, avatarSize, subPath}) => {
  if (!content) {
    content = editor.name;
  }

  if (!avatarSize) {
    avatarSize = 12;
  }

  let gravatar;
  if (editor.gravatar) {
    gravatar = editor.gravatar + '&s=' + (avatarSize * 2);
  }

  return (
    <a href={entityHref(editor, subPath)}>
      {gravatar ? (
        <img src={gravatar} height={avatarSize} width={avatarSize} className="gravatar" alt="" />
      ) : null}
      {isolateText(content)}
    </a>
  );
};

module.exports = EditorLink;
