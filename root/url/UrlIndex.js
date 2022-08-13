/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Relationships
  from '../static/scripts/common/components/Relationships.js';
import isGreyedOut from '../static/scripts/url/utility/isGreyedOut.js';

import UrlLayout from './UrlLayout.js';

type Props = {
  +url: UrlT,
};

const UrlIndex = ({url}: Props): React.Element<typeof UrlLayout> => (
  <UrlLayout entity={url} page="index" title={l('URL Information')}>
    <h2 className="url-details">{l('URL Details')}</h2>
    <table className="details">
      <tr>
        <th>{addColonText(l('URL'))}</th>
        <td>
          {isGreyedOut(url.href_url)
            ? (
              <span
                className="deleted"
                title={l(`This link has been temporarily disabled because
                          it has been reported as potentially harmful.`)}
              >
                {url.href_url}
              </span>
            ) : <a href={url.href_url}>{url.pretty_name}</a>
          }
        </td>
      </tr>
    </table>
    <Relationships source={url} />
  </UrlLayout>
);

export default UrlIndex;
