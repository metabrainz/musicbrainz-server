/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import LabelSidebar from '../layout/components/sidebar/LabelSidebar.js';
import Layout from '../layout/index.js';

import LabelHeader from './LabelHeader.js';

component LabelLayout(
  children: React.Node,
  entity as label: LabelT,
  fullWidth: boolean = false,
  page: string,
  title?: string,
) {
  return (
    <Layout
      title={nonEmpty(title) ? hyphenateTitle(label.name, title) : label.name}
    >
      <div id="content">
        <LabelHeader label={label} page={page} />
        {children}
      </div>
      {fullWidth ? null : <LabelSidebar label={label} />}
    </Layout>
  );
}

export default LabelLayout;
