/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {l} from '../i18n';
import entityHref from '../utility/entityHref';
import isolateText from '../utility/isolateText';

const MissingEditorLink = () => {
  return (
    <span className="deleted tooltip" title={l('This editor is missing from this server, and cannot be displayed correctly.')}>
      {isolateText(l('[missing editor]'))}
    </span>
  );
};

type Props = {|
  +avatarSize?: number,
  +content?: string,
  +editor: EditorT | SanitizedEditorT | null,
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
        <img alt="" className="gravatar" height={avatarSize} src={gravatar} width={avatarSize} />
      ) : null}
      {isolateText(content)}
    </a>
  );
};

export default EditorLink;
