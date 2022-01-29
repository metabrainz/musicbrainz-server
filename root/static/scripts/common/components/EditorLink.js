/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import entityHref from '../utility/entityHref';
import isolateText from '../utility/isolateText';

const MissingEditorLink = (): React.Element<'span'> => {
  return (
    <span
      className="deleted tooltip"
      title={l(
        `This editor is missing from this server,
         and cannot be displayed correctly.`,
      )}
    >
      {isolateText(l('[missing editor]'))}
    </span>
  );
};

type Props = {
  +avatarSize?: number,
  +content?: string,
  +editor: $ReadOnly<{...EditorT, ...}> | null,
  +subPath?: string,
};

const EditorLink = ({
  editor,
  content,
  avatarSize,
  subPath,
}: Props): React.Element<typeof MissingEditorLink | 'a'> => {
  if (!editor) {
    return <MissingEditorLink />;
  }

  if (!content) {
    content = editor.name;
  }

  if (!avatarSize) {
    avatarSize = 12;
  }

  return (
    <a href={entityHref(editor, subPath)}>
      {nonEmpty(editor.avatar) ? (
        <img
          alt=""
          className="avatar"
          height={avatarSize}
          src={editor.avatar}
          width={avatarSize}
        />
      ) : null}
      {isolateText(content)}
    </a>
  );
};

export default EditorLink;
