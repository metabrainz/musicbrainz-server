/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import defaultAvatarUrl from '../../../images/entity/editor.svg';
import entityHref from '../utility/entityHref.js';
import isolateText from '../utility/isolateText.js';

component MissingEditorLink() {
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
}

component EditorLink(
  avatarSize?: number = 15,
  content as passedContent?: string,
  editor: ?$ReadOnly<{...EditorT, ...}>,
  subPath?: string,
) {
  if (!editor) {
    return <MissingEditorLink />;
  }

  let content = passedContent;
  if (empty(content)) {
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
}

export default EditorLink;
