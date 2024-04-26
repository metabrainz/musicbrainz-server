/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import PlaceSidebar from '../layout/components/sidebar/PlaceSidebar.js';
import Layout from '../layout/index.js';

import PlaceHeader from './PlaceHeader.js';

component PlaceLayout(
  children: React$Node,
  entity as place: PlaceT,
  fullWidth: boolean = false,
  page: string,
  title?: string,
) {
  return (
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
}


export default PlaceLayout;
