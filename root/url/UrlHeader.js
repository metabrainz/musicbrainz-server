/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityHeader from '../components/EntityHeader.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';

component UrlHeader(page: string, url: UrlT) {
  return (
    <EntityHeader
      entity={url}
      headerClass="urlheader"
      heading={
        <EntityLink content={url.decoded} entity={url} />
      }
      page={page}
      subHeading={l('URL')}
    />
  );
}

export default UrlHeader;
