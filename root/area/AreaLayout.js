/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import AreaSidebar from '../layout/components/sidebar/AreaSidebar.js';
import Layout from '../layout/index.js';
import localizeAreaName
  from '../static/scripts/common/i18n/localizeAreaName.js';

import AreaHeader from './AreaHeader.js';

component AreaLayout(
  children: React$Node,
  entity as area: AreaT,
  fullWidth: boolean = false,
  page: string,
  title?: string,
) {
  return (
    <Layout
      title={nonEmpty(title)
        ? hyphenateTitle(localizeAreaName(area), title)
        : localizeAreaName(area)}
    >
      <div id="content">
        <AreaHeader area={area} page={page} />
        {children}
      </div>
      {fullWidth ? null : <AreaSidebar area={area} />}
    </Layout>
  );
}

export default AreaLayout;
