/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import type {Node as ReactNode} from 'react';

import Layout from '../layout';
import PlaceSidebar from '../layout/components/sidebar/PlaceSidebar';

import PlaceHeader from './PlaceHeader';

type Props = {|
  +children: ReactNode,
  +entity: PlaceT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
|};

const PlaceLayout = ({
  children,
  entity: place,
  fullWidth,
  page,
  title,
}: Props) => (
  <Layout
    title={title ? hyphenateTitle(place.name, title) : place.name}
  >
    <div id="content">
      <PlaceHeader page={page} place={place} />
      {children}
    </div>
    {fullWidth ? null : <PlaceSidebar place={place} />}
  </Layout>
);


export default PlaceLayout;
