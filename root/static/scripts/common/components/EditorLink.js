/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import defaultAvatarUrl from '../../../images/entity/editor.svg';
import entityHref from '../utility/entityHref.js';
import isolateText from '../utility/isolateText.js';

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
  +editor: ?$ReadOnly<{...EditorT, ...}>,
  +subPath?: string,
};

const EditorLink = ({
  editor,
  content: passedContent,
  avatarSize = 15,
  subPath,
}: Props): React.Element<typeof MissingEditorLink | 'a'> => {
  if (!editor) {
    return <MissingEditorLink />;
  }

  let content = passedContent;
  if (!nonEmpty(content)) {
    content = editor.name;
  }

  const hasAvatar = nonEmpty(editor.avatar);

  return (
    <a href={entityHref(editor, subPath)}>
      <img
        alt=""
        className={'avatar' + (hasAvatar ? '' : ' no-avatar')}
        height={avatarSize}
        src={
          hasAvatar
            ? editor.avatar
            : defaultAvatarUrl
        }
        width={avatarSize}
      />
      {isolateText(content)}
    </a>
  );
};

export default EditorLink;
