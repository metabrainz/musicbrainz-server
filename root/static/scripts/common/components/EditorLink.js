/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const {trim} = require('lodash');
const React = require('react');

const {l} = require('../i18n');
const entityHref = require('../utility/entityHref');
const isolateText = require('../utility/isolateText');

const MissingEditorLink = () => {
  return (
    <span className="deleted tooltip" title={l('This editor is missing from this server, and cannot be displayed correctly.')}>
      {isolateText(l('[missing editor]'))}
    </span>
  );
};

type Props = {|
  +editor: EditorT | SanitizedEditorT | null,
  +content?: string,
  +avatarSize?: number,
  +subPath?: string,
|};

const EditorLink = ({editor, content, avatarSize, subPath}: Props) => {
  if (!editor) {
    return <MissingEditorLink />;
  }

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
