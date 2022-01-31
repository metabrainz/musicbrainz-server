/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import defaultAvatarUrl from '../../../images/entity/editor.svg';
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
    avatarSize = 15;
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
