/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';
import DBDefs from '../static/scripts/common/DBDefs.mjs';
import bugTrackerURL from '../static/scripts/common/utility/bugTrackerURL.js';

import DocSearchBox from './components/DocSearchBox.js';

type Props = {
  +$c: CatalystContextT,
  +id: string,
};

const DocError = ({
  $c,
  id,
}: Props): React.Element<typeof Layout> => {
  // We check whether we have a Google Custom Search engine
  const useGoogleCustomSearch = !!DBDefs.GOOGLE_CUSTOM_SEARCH;

  return (
    <Layout fullWidth title={l('Page Not Found')}>
      <div className="wikicontent" id="content">
        {useGoogleCustomSearch ? <DocSearchBox /> : null}

        <h1>{l('Page Not Found')}</h1>

        <p>
          <strong>
            {texp.l('Sorry, “{id}” is not a valid documentation page.',
                    {id: id.replace(/_/g, ' ')})}
          </strong>
        </p>

        <p>
          {exp.l(`Looking for help? Check out our {doc|documentation}
                  or {faq|FAQ}.`,
                 {
                   doc: '/doc/MusicBrainz_Documentation',
                   faq: '/doc/Frequently_Asked_Questions',
                 })}
        </p>

        <p>
          {exp.l(`Found a broken link on our site? Please let us know by
                  {report|reporting a bug}.`,
                 {
                   report: bugTrackerURL(
                     'Broken link: ' + $c.req.uri + '\n' +
                     'Referrer: ' + $c.req.headers.referer,
                   ),
                 })}
        </p>
      </div>
    </Layout>
  );
};

export default DocError;
