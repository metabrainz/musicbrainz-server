/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import bracketed from '../../static/scripts/common/utility/bracketed.js';
import {
  isBeginner,
  isBot,
} from '../../static/scripts/common/utility/privileges.js';

component EditorTypeInfo(editor: EditorT | null) {
  return (
    editor == null ? null : (
      <>
        {isBeginner(editor) ? (
          <span className="editor-class">
            {bracketed(
              <span
                className="tooltip"
                title={l('This user is new to MusicBrainz.')}
              >
                {l('beginner')}
              </span>,
            )}
          </span>
        ) : null}
        {isBot(editor) ? (
          <span className="editor-class">
            {bracketed(
              <span className="tooltip" title={l('This user is automated.')}>
                {l('bot')}
              </span>,
            )}
          </span>
        ) : null}
      </>
    )
  );
}

export default EditorTypeInfo;
