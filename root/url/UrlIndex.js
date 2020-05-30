/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Relationships from '../components/Relationships';

import UrlLayout from './UrlLayout';

type Props = {
  +$c: CatalystContextT,
  +url: UrlT,
};

const UrlIndex = ({$c, url}: Props): React.Element<typeof UrlLayout> => (
  <UrlLayout $c={$c} entity={url} page="index" title={l('URL Information')}>
    <h2 className="url-details">{l('URL Details')}</h2>
    <table className="details">
      <tr>
        <th>{addColonText(l('URL'))}</th>
        <td><a href={url.href_url}>{url.pretty_name}</a></td>
      </tr>
    </table>
    <Relationships source={url} />
  </UrlLayout>
);

export default UrlIndex;
