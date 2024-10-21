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
    <ErrorLayout title="Image editing unavailable">
      <p>
        <strong>
          {'Images currently cannot be edited while the Internet Archive ' +
           'recovers from a DDoS attack. Follow their '}
          <a href="https://mastodon.archive.org/@internetarchive">
            {'Mastodon account'}
          </a>
          {' for the latest information.'}
        </strong>
      </p>
    </ErrorLayout>
  );
}

export default ImageEditingUnavailable;
