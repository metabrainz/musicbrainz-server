/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import manifest from '../static/manifest.mjs';
import CDTocLink from '../static/scripts/common/components/CDTocLink.js';
import CDTocMediumListTable
  from '../static/scripts/common/components/CDTocMediumListTable.js';
import linkedEntities from '../static/scripts/common/linkedEntities.mjs';

import CDTocInfo from './CDTocInfo.js';

component CDTocIndex(
  cdToc: CDTocT,
  mediumCDTocs: $ReadOnlyArray<MediumCDTocT>,
) {
  return (
    <Layout
      fullWidth
      title={texp.l('Disc ID “{discid}”', {discid: cdToc.discid})}
    >
      <h1>
        {exp.l(
          'Disc ID “<code>{discid}</code>”',
          {discid: <CDTocLink cdToc={cdToc} />},
        )}
      </h1>

      <CDTocInfo cdToc={cdToc} />

      <h2>{l('Attached to releases')}</h2>
      <CDTocMediumListTable
        mediumCDTocs={mediumCDTocs}
        releaseMap={linkedEntities.release}
        showEditColumn
      />
      {manifest(
        'common/components/CDTocMediumListTable',
        {async: true},
      )}
      {manifest(
        'common/components/ReleaseEvents',
        {async: true},
      )}

    </Layout>
  );
}

export default CDTocIndex;
