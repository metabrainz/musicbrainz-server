/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ErrorLayout from './error/ErrorLayout.js';

component ImageEditingUnavailable() {
  return (
    <ErrorLayout title={l('Image editing unavailable')}>
      <p>
        <strong>
          {l('Image editing is currently unavailable.')}
        </strong>
      </p>
    </ErrorLayout>
  );
}

export default ImageEditingUnavailable;
