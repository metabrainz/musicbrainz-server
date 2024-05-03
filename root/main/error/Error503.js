/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ErrorLayout from './ErrorLayout.js';

component Error503() {
  return (
    <ErrorLayout title={l('System busy')}>
      <p>
        <strong>
          {l('The system is overloaded or you are making requests too fast.')}
        </strong>
      </p>

      <p>
        {l('Please wait a few minutes and repeat your request.')}
      </p>
    </ErrorLayout>
  );
}

export default Error503;
