/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FingerprintTable
  from '../static/scripts/common/components/FingerprintTable';

import RecordingLayout from './RecordingLayout';

type Props = {
  +$c: CatalystContextT,
  +recording: RecordingWithArtistCreditT,
};

const RecordingFingerprints = ({
  $c,
  recording,
}: Props): React.Element<typeof RecordingLayout> => (
  <RecordingLayout
    $c={$c}
    entity={recording}
    page="fingerprints"
    title={l('Fingerprints')}
  >
    <h2 id="acoustids">{l('Associated AcoustIDs')}</h2>

    <FingerprintTable recording={recording} />
  </RecordingLayout>
);

export default RecordingFingerprints;
