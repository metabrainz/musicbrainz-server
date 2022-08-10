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
import PlaceSidebar from '../layout/components/sidebar/PlaceSidebar.js';

import PlaceHeader from './PlaceHeader.js';

type Props = {
  +children: React.Node,
  +entity: PlaceT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const PlaceLayout = ({
  children,
  entity: place,
  fullWidth = false,
  page,
  title,
}: Props): React.Element<typeof Layout> => (
  <Layout
    title={nonEmpty(title) ? hyphenateTitle(place.name, title) : place.name}
  >
    <div id="content">
      <PlaceHeader page={page} place={place} />
      {children}
    </div>
    {fullWidth ? null : <PlaceSidebar place={place} />}
  </Layout>
);


export default PlaceLayout;
