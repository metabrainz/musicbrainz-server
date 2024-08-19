/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import escapeClosingTags from '../utility/escapeClosingTags.js';

component DialogResult(
  result: string,
) {
  const script = (
    'window.dialogResult = ' +
    escapeClosingTags(result) +
    ';'
  );
  return (
    <html>
      <head>
        <script dangerouslySetInnerHTML={{__html: script}} />
      </head>
    </html>
  );
}

export default DialogResult;
